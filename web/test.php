<?php

$mysqlserver = "localhost";
$mysqlusername = "root";
$mysqlpassword = "root";

/* Forgive me for I have sinned. */
if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN')
{
    $rEngine = "\"C:\Program Files\R\R-3.2.2\bin\Rscript.exe\" --vanilla ";
    $rScript = "\"C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\analysis\\dummy.R\""; 
    $rCharts = "C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\web\\charts\\";
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
    $rCharts = "/var/www/html/MyApp/charts/";
}

$selected_area_id = $_POST["ddlAreas"];
$selected_category_id = $_POST["ddlCategories"];
$selected_agg_alg_id = $_POST["ddlAggAlg"];

?>

<script src="js/jquery-1.11.3.min.js" type="text/javascript"></script>

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

    <select id="ddlAggAlg" name="ddlAggAlg">
        <option value='-1'>[Please select an aggregation algorithm]</option>
        <option value='0' <?php echo (($selected_agg_alg_id=='0') ? ' selected' : ''); ?> >Original Numerical</option>
        <option value='1' <?php echo (($selected_agg_alg_id=='1') ? ' selected' : ''); ?> >Standardized Numerical</option>
        <option value='2' <?php echo (($selected_agg_alg_id=='2') ? ' selected' : ''); ?> >Multinomial Frequency</option>
        <option value='3' <?php echo (($selected_agg_alg_id=='3') ? ' selected' : ''); ?> >Relative Rank</option>
    </select>

    <br />
    <br />

    <input type="submit" name="btnAnalyze" value="Analyze"/>

    <br />
    <br />

    <?php

    $t = explode(' ', microtime());
    $t = ltrim($t[0] + $t[1]);

    /* to see errors add '2>&1' to the string below */
    $cmd = sprintf("%s %s %s %s %d %d %d %d %d %d %d 2>&1", $rEngine, $rScript, $rCharts,
        $t, $selected_area_id, $selected_category_id, -1, -1, -1, -1, $selected_user_norm_id);
    $result = system($cmd);

    echo ($cmd . "<br />" . $result . "<br />");
    echo("<img src='charts/" . $t . "/chart1.png' />");
    ?>

</form>
