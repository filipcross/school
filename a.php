<?php
session_start();


$randomNumber = rand(1, 100);
$_SESSION['randomNumber'] = $randomNumber; 
?>

<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <title>A - Přenos hodnoty</title>
</head>
<body>
    <h1>Přenos hodnoty z a.php do b.php</h1>
    <p>Vygenerované číslo: <strong><?php echo $randomNumber; ?></strong></p>

    <h2>Odkazy</h2>
    <!-- GET -->
    <a href="b.php?value=<?php echo $randomNumber; ?>">Předat hodnotu pomocí GET</a><br>

    <!-- POST -->
    <form action="b.php" method="post">
        <input type="hidden" name="value" value="<?php echo $randomNumber; ?>">
        <button type="submit">Předat hodnotu pomocí POST</button>
    </form><br>

    <!-- SESSION -->
    <form action="b.php" method="get">
        <input type="hidden" name="useSession" value="true">
        <button type="submit">Předat hodnotu pomocí SESSION</button>
    </form>
</body>
</html>