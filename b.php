<?php
session_start();


$value = null;

if (isset($_GET['value'])) {
    $value = $_GET['value'];
    $method = "GET";
} elseif (isset($_POST['value'])) {
    $value = $_POST['value'];
    $method = "POST";
} elseif (isset($_GET['useSession']) && $_GET['useSession'] === 'true') {
    $value = $_SESSION['randomNumber'] ?? null;
    $method = "SESSION";
} else {
    $method = "Neznámý";
}
?>

<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <title>B - Zobrazení hodnoty</title>
</head>
<body>
    <h1>Zobrazení přijaté hodnoty</h1>
    <?php if ($value !== null): ?>
        <p>Přijatá hodnota: <strong><?php echo htmlspecialchars($value); ?></strong></p>
        <p>Způsob přenosu: <strong><?php echo $method; ?></strong></p>
    <?php else: ?>
        <p>Hodnota nebyla předána.</p>
    <?php endif; ?>
</body>
</html>
