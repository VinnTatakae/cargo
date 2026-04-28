<?php

namespace App\Controllers;

use CodeIgniter\RESTful\ResourceController;

class CategoryController extends ResourceController
{
    protected $modelName = 'App\Models\CategoryModel';
    protected $format = 'json';

    // 🔐 ambil user dari token
    private function getUserFromToken()
    {
        $header = $this->request->getHeaderLine("Authorization");

        if (!$header) return null;

        $token = str_replace("Bearer ", "", $header);
        $decoded = base64_decode($token);

        if (!$decoded) return null;

        $parts = explode('|', $decoded);
        $userId = $parts[0] ?? null;

        if (!$userId) return null;

        $userModel = new \App\Models\UserModel();
        return $userModel->find($userId);
    }

    // 🔹 GET /categories
    public function index()
    {
        return $this->respond($this->model->findAll());
    }

    // 🔹 POST /categories (ADMIN ONLY)
    public function create()
    {
        $user = $this->getUserFromToken();

        if (!$user || $user['role'] !== 'admin') {
            return $this->failForbidden("Only admin can create category");
        }

        $data = $this->request->getJSON(true);

        if (!isset($data['name'])) {
            return $this->fail("Category name required", 400);
        }

        $this->model->insert([
            'name' => $data['name']
        ]);

        return $this->respondCreated([
            'message' => 'Category created'
        ]);
    }

    // 🔹 PUT /categories/{id}
    public function update($id = null)
    {
        $user = $this->getUserFromToken();

        if (!$user || $user['role'] !== 'admin') {
            return $this->failForbidden("Only admin can update category");
        }

        $data = $this->request->getJSON(true);

        $this->model->update($id, [
            'name' => $data['name']
        ]);

        return $this->respond([
            'message' => 'Category updated'
        ]);
    }

    // 🔹 DELETE /categories/{id}
    public function delete($id = null)
    {
        $user = $this->getUserFromToken();

        if (!$user || $user['role'] !== 'admin') {
            return $this->failForbidden("Only admin can delete category");
        }

        $this->model->delete($id);

        return $this->respondDeleted([
            'message' => 'Category deleted'
        ]);
    }
}