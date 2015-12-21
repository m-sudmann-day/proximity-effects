<title>Proximity Effects on Consumer Sentiment</title> 
<link rel="stylesheet" type="text/css" href="style.css" />
<script src="js/jquery-1.11.3.min.js" type="text/javascript"></script>
<script src="js/navbar.js" type="text/javascript"></script>

<div id="header"><h1>Proximity Effects on Consumer Sentiment</h1></div>

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
                $cmd = sprintf("%s %s %s %d %d", $rEngine, $rScript, $rCharts, #  >&1 2>&1
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
        
        if ($atLeastOneFile && $isPost)
        {
            echo("In all of the charts below, each point is an individual business.  The X-axis represents  the distance to the closest competitor of that business in kilometres.  For US cities, this value is adjusted slightly to compensate for population density variation within the sample.  Assuming enough data is available for each chart, the following are the charts that appear below:<br /><br />");
            echo("1) <b>Yelp Stars vs. Distance</b>: These are the raw star ratings as calculated by Yelp’s own algorithm.  This is for demonstration purposes only.<br /><br />");
            echo("2) <b>Standardized Median Absolute Deviation of Rating vs. Distance</b>: The ratings that we assign to each business after standardizing individual reviewers and individual review.  The Y-axis represents the businesses’ number of (MAD) deviations from the median.<br /><br />");
            echo("3) <b>Difference Between Standardized MAD Rating of Closest Competitors vs. Distance</b>: Again each point is a business, but the Y-axis is the difference between the number of deviations from the median that the two business have, or the difference in consumer sentiment.  The red fit line depicts the correlation of distance between competitors to difference in consumer sentiment.<br /><br />");
            echo("4) <b>Difference Between Standardized MAD Rating Against 3 Closest Competitors vs. Distance</b>: This is similar to the previous chart, but typically a diluted result.  The distances and ratings of the three closest competitors are merged into a single value using inverse distance weighting then compared against the plotted businesses to generated the Y-axis value.<br /><br />");
            echo("5) <b>Standard Deviation of Standardized MAD Ratings vs. Distance</b>:  This chart digs one level deeper and looks at the standard deviation of individual standardized reviews for each business plotted against the distance to the nearest competitor.  The fit line shows the correlation between this level of variance and the distance to the closest competitor.<br /><br />");
            echo("Interpretation of the results is left to the reader.  The slopes and significances vary greatly between business categories and somewhat between geographies.  The title of each chart shows how many businesses are included in the analysis.");
        }
        ?>
</form>

</div>
