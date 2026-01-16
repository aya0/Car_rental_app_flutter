<?php
require_once "db.php";

$type = trim($_GET['type'] ?? '');
$q    = trim($_GET['q'] ?? '');
$minP = trim($_GET['minPrice'] ?? '');
$maxP = trim($_GET['maxPrice'] ?? '');

$sql = "
SELECT
  c.car_id, c.brand, c.model, c.model_year, c.type,
  c.seats, c.transmission, c.fuel_type, c.daily_price, c.status,
  (SELECT image_name FROM car_images WHERE car_id = c.car_id ORDER BY sort_order ASC LIMIT 1) AS cover_image
FROM cars c
WHERE c.status = 'AVAILABLE'
";

$params = [];

if ($type !== '' && $type !== 'ALL') {
  $sql .= " AND c.type = :type";
  $params[':type'] = $type;
}

if ($q !== '') {
  $sql .= " AND (c.brand LIKE :q OR c.model LIKE :q)";
  $params[':q'] = "%$q%";
}

if ($minP !== '' && is_numeric($minP)) {
  $sql .= " AND c.daily_price >= :minP";
  $params[':minP'] = (float)$minP;
}

if ($maxP !== '' && is_numeric($maxP)) {
  $sql .= " AND c.daily_price <= :maxP";
  $params[':maxP'] = (float)$maxP;
}

$sql .= " ORDER BY c.daily_price ASC";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);

echo json_encode(["ok" => true, "data" => $stmt->fetchAll()]);