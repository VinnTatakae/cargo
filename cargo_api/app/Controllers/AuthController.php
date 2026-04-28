<?php

namespace App\Controllers;

use App\Models\UserModel;
use CodeIgniter\RESTful\ResourceController;

class AuthController extends ResourceController
{
    public function login()
    {
        $data = $this->request->getJSON(true);

        // 🔒 VALIDASI BASIC
        if (!isset($data['email']) || !isset($data['password'])) {
            return $this->fail("Email and password are required", 400);
        }

        // 🔥 FIX UTAMA (trim + lowercase)
        $email = strtolower(trim($data['email']));
        $password = trim($data['password']);

        $userModel = new UserModel();

        // 🔥 FIX QUERY (biar gak case sensitive)
        $user = $userModel
            ->where('LOWER(email)', $email)
            ->first();

        if (!$user) {
            return $this->fail("User not found", 404);
        }

        if (!password_verify($password, $user['password'])) {
            return $this->fail("Wrong password", 401);
        }

        // 🔥 TOKEN
        $token = base64_encode($user['id'] . '|' . bin2hex(random_bytes(16)));

        // 🔐 HAPUS PASSWORD
        unset($user['password']);

        return $this->respond([
            "token" => $token,
            "user" => $user
        ]);
    }

    public function register()
    {
        $data = $this->request->getJSON(true);

        // 🔒 VALIDASI
        if (!isset($data['email'], $data['password'], $data['name'])) {
            return $this->fail("Incomplete data", 400);
        }

        $userModel = new UserModel();

        // 🔥 NORMALISASI EMAIL
        $email = strtolower(trim($data['email']));

        // 🔍 CEK EMAIL SUDAH ADA
        if ($userModel->where('LOWER(email)', $email)->first()) {
            return $this->fail("Email already registered", 400);
        }

        // 🔐 HASH PASSWORD
        $hashedPassword = password_hash(trim($data['password']), PASSWORD_DEFAULT);

        // 🔹 DATA FINAL
        $newUser = [
            "name" => $data['name'],
            "email" => $email,
            "password" => $hashedPassword,
            "role" => $data['role'] ?? 'user'
        ];

        $userModel->insert($newUser);

        return $this->respondCreated([
            "message" => "Register success"
        ]);
    }
}