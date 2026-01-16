<?php
require_once "db.php";

$id = (int)($_GET['id'] ?? 0);
if ($id <= 0) {
  http_response_code(400);
  echo json_encode(["ok" => false, "message" => "Invalid car id"]);
  exit;
}

$stmt = $pdo->prepare("
  SELECT car_id, plate_number, brand, model, model_year, type, seats,
         transmission, fuel_type, daily_price, status, description
  FROM cars
  WHERE car_id = :id
  LIMIT 1
");
$stmt->execute([":id" => $id]);
$car = $stmt->fetch();

if (!$car) {
  http_response_code(404);
  echo json_encode(["ok" => false, "message" => "Car not found"]);
  exit;
}

$img = $pdo->prepare("SELECT image_name, sort_order FROM car_images WHERE car_id = :id ORDER BY sort_order ASC");
$img->execute([":id" => $id]);
$images = $img->fetchAll();

echo json_encode([
  "ok" => true,
  "car" => $car,
  "images" => $images
]);