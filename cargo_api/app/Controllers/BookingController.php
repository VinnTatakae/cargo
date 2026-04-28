<?php

namespace App\Controllers;

use CodeIgniter\RESTful\ResourceController;

class BookingController extends ResourceController
{
    protected $modelName = 'App\Models\BookingModel';
    protected $format = 'json';

    // 🔹 helper ambil user dari token (VERSI BARU)
    private function getUserFromToken()
    {
        $header = $this->request->getHeaderLine("Authorization");

        if (!$header) return null;

        $token = str_replace("Bearer ", "", $header);

        $decoded = base64_decode($token);

        if (!$decoded) return null;

        // 🔥 format: user_id|random
        $parts = explode('|', $decoded);
        $userId = $parts[0] ?? null;

        if (!$userId) return null;

        $userModel = new \App\Models\UserModel();
        return $userModel->find($userId);
    }

    // 🔹 GET /bookings (history user)
    public function index()
    {
        $user = $this->getUserFromToken();

        if (!$user) {
            return $this->failUnauthorized("Invalid token");
        }

        $db = \Config\Database::connect();
        $builder = $db->table('bookings');

        $builder->select('bookings.*, cars.name as car_name');
        $builder->join('cars', 'cars.id = bookings.car_id');
        $builder->join('payments', 'payments.booking_id = bookings.id', 'left');

        if ($user['role'] !== 'admin') {
            $builder->where('bookings.user_id', $user['id']);
        }

        $data = $builder->get()->getResultArray();

        return $this->respond($data);
    }

    
    // 🔹 POST /bookings
    public function create()
    {
        $user = $this->getUserFromToken();

        if (!$user) {
            return $this->failUnauthorized("Invalid token");
        }

        $data = $this->request->getJSON(true);

        // 🔒 VALIDASI BASIC
        if (!isset($data['car_id'], $data['start_date'], $data['end_date'])) {
            return $this->fail("Incomplete booking data", 400);
        }

        // 🔹 cek bentrok booking
        $existing = $this->model
            ->where('car_id', $data['car_id'])
            ->whereIn('status', ['pending', 'approved'])
            ->groupStart()
                ->where('start_date <', $data['end_date'])
                ->where('end_date >', $data['start_date'])
            ->groupEnd()
            ->findAll();

        if ($existing) {
            return $this->fail('Car already booked on selected dates', 400);
        }

        // 🔹 ambil data mobil
        $carModel = new \App\Models\CarModel();
        $car = $carModel->find($data['car_id']);

        if (!$car) {
            return $this->failNotFound('Car not found');
        }

        // 🔹 hitung jumlah hari
        $start = new \DateTime($data['start_date']);
        $end = new \DateTime($data['end_date']);
        $days = $start->diff($end)->days;

        if ($days <= 0) {
            return $this->fail('Invalid date range', 400);
        }

        // 🔹 hitung total harga
        $totalPrice = $days * $car['price_per_day'];

        // 🔥 inject data dari server (AMAN)
        $insertData = [
            'user_id' => $user['id'],
            'car_id' => $data['car_id'],
            'start_date' => $data['start_date'],
            'end_date' => $data['end_date'],
            'total_price' => $totalPrice,
            'status' => 'pending'
        ];

        $this->model->insert($insertData);

        $bookingId = $this->model->getInsertID(); // 🔥 AMBIL ID

        return $this->respondCreated([
            'message' => 'Booking created successfully',
            'booking_id' => $bookingId, // 🔥 WAJIB
            'total_price' => $totalPrice
        ]);
    }

    // 🔹 PUT /bookings/{id}
    public function update($id = null)
    {
        $user = $this->getUserFromToken();

        if (!$user) {
            return $this->failUnauthorized("Invalid token");
        }

        $data = $this->request->getJSON(true);

        $booking = $this->model->find($id);

        if (!$booking) {
            return $this->failNotFound('Booking not found');
        }

        // 🔒 hanya admin yang boleh update
        if ($user['role'] !== 'admin') {
            return $this->failForbidden("Only admin can update booking");
        }

        if ($booking['status'] !== 'pending') {
            return $this->fail('Booking already processed', 400);
        }

        $allowedStatus = ['approved', 'rejected', 'cancelled'];

        if (!isset($data['status']) || !in_array($data['status'], $allowedStatus)) {
            return $this->fail('Invalid status', 400);
        }

        $this->model->update($id, ['status' => $data['status']]);

        return $this->respond([
            'message' => 'Booking status updated successfully'
        ]);
    }

    // 🔹 PUT /bookings/{id}/cancel (USER)
    public function cancel($id = null)
    {
        $user = $this->getUserFromToken();

        if (!$user) {
            return $this->failUnauthorized("Invalid token");
        }

        $booking = $this->model->find($id);

        if (!$booking) {
            return $this->failNotFound('Booking not found');
        }

        // 🔒 hanya pemilik booking
        if ($booking['user_id'] != $user['id']) {
            return $this->failForbidden("Not your booking");
        }

        // 🔒 hanya bisa cancel kalau masih pending
        if ($booking['status'] !== 'pending') {
            return $this->fail('Only pending booking can be cancelled', 400);
        }

        $this->model->update($id, [
            'status' => 'cancelled'
        ]);

        return $this->respond([
            'message' => 'Booking cancelled'
        ]);
    }
}