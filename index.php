<?php
/**
 * Front controller — semua request masuk ke sini.
 */
declare(strict_types=1);

session_start();

define('BASE_PATH', __DIR__);

$scriptName = str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? ''));
$scriptName = rtrim($scriptName, '/');
define('BASE_URL', $scriptName === '' || $scriptName === '/' ? '' : $scriptName);

if (!isset($_GET['url']) && !empty($_SERVER['REQUEST_URI'])) {
    $requestUri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '/';
    $requestUri = rawurldecode($requestUri);
    $basePath = rtrim(BASE_URL, '/');

    if ($basePath !== '' && str_starts_with($requestUri, $basePath . '/')) {
        $requestUri = substr($requestUri, strlen($basePath));
    }

    $requestUri = trim($requestUri, '/');
    if ($requestUri !== '' && !preg_match('/\.[A-Za-z0-9]+$/', $requestUri)) {
        $_GET['url'] = $requestUri;
    }
}

$configApp = require BASE_PATH . '/config/app.php';
date_default_timezone_set($configApp['timezone'] ?? 'Asia/Jakarta');

// Autoload Composer (Dompdf) jika tersedia
$composerAutoload = BASE_PATH . '/vendor/autoload.php';
if (is_file($composerAutoload)) {
    require $composerAutoload;
}

require BASE_PATH . '/core/Autoloader.php';
App\Core\Autoloader::register();

use App\Core\Router;

$router = new Router();
$router->dispatch($_GET['url'] ?? '');
