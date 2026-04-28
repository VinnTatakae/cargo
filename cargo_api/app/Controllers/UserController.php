<?php

namespace App\Controllers;

use App\Models\UserModel;
use CodeIgniter\RESTful\ResourceController;

class UserController extends ResourceController
{
    protected $modelName = 'App\Models\UserModel';
    protected $format    = 'json';

    // 🔹 GET /users
    public function index()
    {
        return $this->respond($this->model->findAll());
    }

    // 🔹 POST /users
    public function create()
    {
        $data = $this->request->getJSON(true);

        // 🔐 Hash password
        $data['password'] = password_hash($data['password'], PASSWORD_DEFAULT);

        $this->model->insert($data);

        return $this->respondCreated([
            'message' => 'User created successfully'
        ]);
    }

    // 🔹 PUT /users/{id}
    public function update($id = null)
    {
        $data = $this->request->getJSON(true);

        // Kalau ada password baru → hash
        if (isset($data['password'])) {
            $data['password'] = password_hash($data['password'], PASSWORD_DEFAULT);
        }

        $this->model->update($id, $data);

        return $this->respond([
            'message' => 'User updated successfully'
        ]);
    }

    // 🔹 DELETE /users/{id}
    public function delete($id = null)
    {
        $this->model->delete($id);

        return $this->respondDeleted([
            'message' => 'User deleted successfully'
        ]);
    }
}