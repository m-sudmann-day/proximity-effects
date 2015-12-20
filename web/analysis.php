<title>Proximity Effects on Customer Sentiment</title> 
<link rel="stylesheet" type="text/css" href="style.css" />
<script src="js/jquery-1.11.3.min.js" type="text/javascript"></script>
<script src="js/navbar.js" type="text/javascript"></script>

<div id="header"><h1>Proximity Effects on Customer Sentiment</h1></div>

<div id="menu">
    <a id="home_link" href="index.php" onclick="show_content('home'); return false;">Home</a> &middot;
    <a id="data_link" href="data.php" onclick="show_content('data'); return false;">Data</a> &middot;
    <a id="analysis_link" href="analysis.php" class="active" onclick="show_content('analysis'); return false;">Analysis</a>
</div>

<?php
$mysqlserver = "localhost";
$mysqlusername = "root";
$mysqlpassword = "";

/* Forgive me for I have sinned. */
$isWin = (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN');
$isPost = ($_SERVER['REQUEST_METHOD'] == 'POST');
$t = explode(' ', microtime());
$t = ltrim($t[0] + $t[1]);

if ($isWin)
{
    $rEngine = "\"C:\Program Files\R\R-3.2.2\bin\Rscript.exe\" --vanilla ";
    $rScript = "\"C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\analysis\\analysis.R\"";
    $rCharts = "C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\web\\charts\\" . $t;
}
else
{
    $rEngine = "/usr/bin/Rscript --vanilla ";
    $rScript = "/home/ubuntu/projects/proximity-effects/analysis/analysis.R";
    $rCharts = "/var/www/html/MyApp/charts/" . $t;
}

$selected_area_id = $_POST["ddlAreas"];
$selected_category_id = $_POST["ddlCategories"];
?>

<form name="frmMain" method="post" action="analysis.php">

    <div id="main" style="width:99%; margin:0px; padding:0px; font-size:16; margin-left:30px; margin-right:30px">

        <br />
        <br />

        Select a business category and geographical area to analyze.

        <br />
        <br />

        <table style="width:100%; align-content:center; align-items:center; align-self:center;">

            <tr>
                <td style='text-align:center; width:100%'>

                    Analyze&nbsp;<select id="ddlCategories" name="ddlCategories">
                        <option value="-1">[Category]</option>
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

                    &nbsp;in&nbsp;<select id="ddlAreas" name="ddlAreas">
                        <option value="-1">[Area]</option>
                        <?php
                        $link = mysql_connect(localhost, $mysqlusername, $mysqlpassword)
                            or die ("Error connecting to mysql server: ".mysql_error());
                        $areas = mysql_query("call proximity_effects.GetAllAreas();", $link);
                        while ($area = mysql_fetch_assoc($areas)) {
                            echo "<option value='" . $area['ID'] . "'" .
                            (($area['ID']==$selected_area_id)?' selected':'') . ">" . $area['Name'] . "</option>";
                        }
                        mysql_close($link);
                        ?>
                    </select>

                    &nbsp;<input type="submit" name="btnAnalyze" value="Go" />

                </td>
            </tr>

            <?php
            $atLeastOneFile = FALSE;

            if ($isPost && $selected_area_id != -1 && $selected_category_id != -1)
            {
                $cmd = sprintf("%s %s %s %d %d 2>&1", $rEngine, $rScript, $rCharts, #  >&1 2>&1
                    $selected_area_id, $selected_category_id);
                $result = system($cmd);
                $files = $rCharts . ".*";
                foreach(glob($files) as $file)
                {
                    $atLeastOneFile = TRUE;
                    echo("<tr><td>&nbsp;</td></tr>");
                    echo("<tr><td style='width:100%; text-align:center; align:center'><img style='min-width:800px' src='charts/"
                    . basename($file) . "'/></td></tr>");
                }
            }
            ?>

        </table>

        <?php
        if (!$atLeastOneFile && $isPost)
        {
            echo("<br /><br />The combination of geographic area and business category that you selected did not contain enough businesses to perform an analysis.");
        }
        ?>
</form>

</div>
