<?php

namespace App\Controllers;

use App\Models\CarModel;
use CodeIgniter\RESTful\ResourceController;

class CarController extends ResourceController
{
    protected $modelName = 'App\Models\CarModel';
    protected $format    = 'json';

    
    // 🔹 GET /cars
    public function index()
    {
        $db = \Config\Database::connect();

        $builder = $db->table('cars');
        $builder->select('cars.*, categories.name as category_name');
        $builder->join('categories', 'categories.id = cars.category_id', 'left');

        $cars = $builder->get()->getResultArray();

        return $this->respond($cars);
    }

    // 🔹 POST /cars
    public function create()
    {
        $data = $this->request->getJSON(true);

        $this->model->insert($data);

        return $this->respondCreated([
            'message' => 'Car created successfully'
        ]);
    }

    // 🔹 PUT /cars/{id}
    public function update($id = null)
    {
        $data = $this->request->getJSON(true);

        // 🔥 PAKSA CAST
        if (isset($data['category_id'])) {
            $data['category_id'] = (int)$data['category_id'];
        }

        $this->model->update($id, $data);

        return $this->respond([
            'message' => 'Car updated successfully',
            'data' => $data
        ]);
    }
    
    // 🔹 DELETE /cars/{id}
    public function delete($id = null)
    {
        $this->model->delete($id);

        return $this->respondDeleted([
            'message' => 'Car deleted successfully'
        ]);
    }
    
}