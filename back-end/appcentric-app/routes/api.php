<?php
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\SubjectController;
use App\Http\Controllers\API\PaperController;

// Public routes
Route::post('/auth/login', [AuthController::class, 'login']);

// Protected routes with rate limiting
Route::middleware(['auth:sanctum', 'throttle:50,1'])->group(function () {
    // Auth routes
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/user', [AuthController::class, 'user']);
    
    // Subject routes
    Route::get('/subjects', [SubjectController::class, 'index']);
    
    // Paper routes
    Route::get('/papers', [PaperController::class, 'index']);
    Route::get('/papers/{id}', [PaperController::class, 'show']);
});

