<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');
$routes->get('/cars', 'CarController::index');
$routes->post('/cars', 'CarController::create');
$routes->put('/cars/(:num)', 'CarController::update/$1');
$routes->delete('/cars/(:num)', 'CarController::delete/$1');
$routes->get('/users', 'UserController::index');
$routes->post('/users', 'UserController::create');
$routes->put('/users/(:num)', 'UserController::update/$1');
$routes->delete('/users/(:num)', 'UserController::delete/$1');
$routes->get('/bookings', 'BookingController::index');
$routes->post('/bookings', 'BookingController::create');
$routes->put('/bookings/(:num)', 'BookingController::update/$1');
$routes->options('(:any)', function() {
    return response()->setStatusCode(200);
});
$routes->post('auth/login', 'AuthController::login');
$routes->post('auth/register', 'AuthController::register');
$routes->options('auth/(:any)', function () {
    return response()->setStatusCode(200);
});
$routes->get('/categories', 'CategoryController::index');
$routes->post('/categories', 'CategoryController::create');
$routes->put('categories/(:num)', 'CategoryController::update/$1');
$routes->delete('categories/(:num)', 'CategoryController::delete/$1');
$routes->get('/payments', 'PaymentController::index');
$routes->post('/payments', 'PaymentController::create');
$routes->get('/payments/(:num)', 'PaymentController::show/$1');
$routes->put('/payments/(:num)', 'PaymentController::update/$1');
$routes->resource('categories');
$routes->put('bookings/(:num)/cancel', 'BookingController::cancel/$1');
$routes->post('payments/refund/(:num)', 'PaymentController::refund/$1');