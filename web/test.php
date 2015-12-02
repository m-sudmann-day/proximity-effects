
<?php

$mysqlserver = "localhost";
$mysqlusername = "root";
$mysqlpassword = "root";

/* Forgive me for I have sinned. */
$isWin = (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN');
$t = explode(' ', microtime());
$t = ltrim($t[0] + $t[1]);

if ($isWin)
{
    $rEngine = "\"C:\Program Files\R\R-3.2.2\bin\Rscript.exe\" --vanilla ";
    $rScript = "\"C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\analysis\\dummy.R\""; 
    $rCharts = "C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\web\\charts\\" . $t;
}
 else
{
    /*
    $rEngine = "/home/ubuntu/projects/proximity-effects/analysis/Rscript --vanilla ";
    $rScript = "/home/ubuntu/projects/proximity-effects/analysis/dummy.R";
    $rCharts = "/var/www/html/MyApp/charts/";
    */

    $rEngine = "/usr/bin/Rscript --vanilla ";
    $rScript = "/home/ubuntu/projects/proximity-effects/analysis/dummy.R";
    $rCharts = "/var/www/html/MyApp/charts/" . $t;
}

$selected_area_id = $_POST["ddlAreas"];
$selected_category_id = $_POST["ddlCategories"];

?>

<script src="js/jquery-1.11.3.min.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="style.css" media="screen" />

<form name="frmMain" method="post" action="test.php">
    
    <select id="ddlAreas" name="ddlAreas">
        <option value="-1">[Please select a city]</option>
        <?php
        $link = mysql_connect(localhost, $mysqlusername, $mysqlpassword)
            or die ("Error connecting to mysql server: ".mysql_error());
        $areas = mysql_query("call proximity_effects.GetAllAreas();", $link);
        while ($area = mysql_fetch_assoc($areas)) {
            $name = $area['Name'] . " (" . $area['BusinessCount'] . ")";
            echo "<option value='" . $area['ID'] . "'" .
                (($area['ID']==$selected_area_id)?' selected':'') .
                ">" . $name . "</option>";
        }
        mysql_close($link);
        ?>
    </select>

    <br />
    <br />

    <select id="ddlCategories" name="ddlCategories">
        <option value="-1">[Please select a category]</option>
        <?php
        $link = mysql_connect(localhost, $mysqlusername, $mysqlpassword)
            or die ("Error connecting to mysql server: ".mysql_error());
        $categories = mysql_query("call proximity_effects.GetAllCategories();", $link);
        while ($category = mysql_fetch_assoc($categories)) {
            $name = $category['Name'];
            echo "<option value='" . $category['ID'] . "'" .
                (($category['ID']==$selected_category_id)?' selected':'') .
                ">" . $name . "</option>";
        }
        mysql_close($link);
        ?>
    </select>

    <br />
    <br />

    <input type="submit" name="btnAnalyze" value="Analyze"/>
     
    <table style="width:95%">

    <?php

    $cmd = sprintf("%s %s %s %d %d %d", $rEngine, $rScript, $rCharts, #  >&1 2>&1
        $selected_area_id, $selected_category_id, $selected_agg_alg_id);
    $result = system($cmd);

    $files = $rCharts . ".*";
    foreach(glob($files) as $file)
    {
        echo("<tr><td style='width:100%; text-align:center'><img align='middle' border='0' src='charts/" . basename($file) . "'/></td></tr>");
    }

    ?>

    </table>

</form>
