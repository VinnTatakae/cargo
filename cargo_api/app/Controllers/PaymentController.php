<?php

namespace App\Controllers;

use CodeIgniter\RESTful\ResourceController;

class PaymentController extends ResourceController
{
    protected $modelName = 'App\Models\PaymentModel';
    protected $format    = 'json';

    public function create()
    {
        $data = $this->request->getJSON(true);

        if (!isset($data['booking_id'], $data['method'])) {
            return $this->fail("Incomplete payment data", 400);
        }

        // 🔥 CEK SUDAH PERNAH BAYAR
        $existing = $this->model
            ->where('booking_id', $data['booking_id'])
            ->first();

        if ($existing) {
            return $this->fail("Already paid", 400);
        }

        // 🔥 INSERT PAYMENT (TANPA UBAH BOOKING)
        $this->model->insert([
            'booking_id' => $data['booking_id'],
            'method' => $data['method'],
            'status' => 'paid'
        ]);

        return $this->respondCreated([
            'message' => 'Payment success'
        ]);
    }
    
    public function refund($bookingId)
    {
        $payment = $this->model
            ->where('booking_id', $bookingId)
            ->first();

        if (!$payment || $payment['status'] !== 'paid') {
            return $this->fail("Cannot refund", 400);
        }

        // 🔥 UPDATE PAYMENT
        $this->model->update($payment['id'], [
            'status' => 'refunded'
        ]);

        // 🔥 UPDATE BOOKING
        $bookingModel = new \App\Models\BookingModel();
        $bookingModel->update($bookingId, [
            'status' => 'cancelled'
        ]);

        return $this->respond([
            'message' => 'Refund success'
        ]);

        if (!in_array($booking['status'], ['rejected', 'cancelled'])) {
            return $this->fail("Refund not allowed", 400);
        }
    }
}