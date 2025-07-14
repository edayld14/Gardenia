<?php
require 'vendor/autoload.php'; // Stripe PHP SDK'yı dahil et

\Stripe\Stripe::setApiKey('yourkey'); // Stripe gizli anahtar

header('Content-Type: application/json');

$input = json_decode(file_get_contents('php://input'), true);
$amount = $input['amount']; // Örnek: 1099 = 10.99 TL

try {
    $paymentIntent = \Stripe\PaymentIntent::create([
        'amount' => $amount,
        'currency' => 'try',
    ]);
    echo json_encode(['clientSecret' => $paymentIntent->client_secret]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
