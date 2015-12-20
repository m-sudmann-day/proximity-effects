<title>Proximity Effects on Consumer Sentiment</title>
<link rel="stylesheet" type="text/css" href="style.css" />
<script src="js/navbar.js" type="text/javascript"></script>

<div id="header"><h1>Proximity Effects on Consumer Sentiment</h1></div>

<div id="menu">
    <a id="home_link" href="index.php" onclick="show_content('home'); return false;">Home</a> &middot;
    <a id="data_link" href="data.php" class="active" onclick="show_content('data'); return false;">Data</a> &middot;
    <a id="analysis_link" href="analysis.php" onclick="show_content('analysis'); return false;">Analysis</a>
</div>

<div id="main" style="width:99%; margin:0px; padding:0px; font-size:16; margin-left:30px; margin-right:30px">

<?php
$mysqlserver = "localhost";
$mysqlusername = "root";
$mysqlpassword = "";
?>

<br /><br />

The following table shows the geographical areas covered by our dataset, and the number of businesses within each area.

<br /><br />

<table border='1'>
    <tr>
        <td style='text-align:right'><b>&nbsp;&nbsp;Area&nbsp;&nbsp;</b></td>
        <td><b>&nbsp;&nbsp;Business&nbsp;Count&nbsp;&nbsp;</b></td>
    </tr>

    <?php
    $link = mysql_connect($mysqlserver, $mysqlusername, $mysqlpassword)
        or die ("Error connecting to mysql server: ".mysql_error());

    $areas = mysql_query(
        "select a.Name, count(*) Count
        from proximity_effects.Business b
        inner join proximity_effects.Area a on b.areaid = a.id
        where a.Name != 'Miscellaneous'
        group by a.id
        order by count(*) desc;", $link);

    while ($area = mysql_fetch_assoc($areas)) {
        echo "<tr><td style='text-align:right'>&nbsp;&nbsp;" . $area['Name'] . "&nbsp;&nbsp;</td><td>&nbsp;&nbsp;" . $area['Count'] . "&nbsp;&nbsp;</td></tr>";
    }
    mysql_close($link);
    ?>

</table>

<br /><br />

The following table shows the top twenty business categories covered by our dataset, and the number of businesses within each category.  Note that many categories overlap and most businesses belong to more than one category.

<br /><br />

<table border='1'>
    <tr>
        <td style='text-align:right'><b>&nbsp;&nbsp;Area&nbsp;&nbsp;</b></td>
        <td><b>&nbsp;&nbsp;Business&nbsp;Count&nbsp;&nbsp;</b></td>
    </tr>

    <?php
    $link = mysql_connect($mysqlserver, $mysqlusername, $mysqlpassword)
        or die ("Error connecting to mysql server: ".mysql_error());

    $categories = mysql_query(
        "select c.Name, sub.Count
        from
        (select count(*) Count, bc.categoryid
        from proximity_effects.Business b
        inner join proximity_effects.BusinessCategory bc on b.id = bc.businessid
        group by bc.categoryid
        order by count(*) desc
        limit 20) sub
        inner join proximity_effects.Category c on sub.categoryid = c.id;", $link);

    while ($category = mysql_fetch_assoc($categories)) {
        echo "<tr><td style='text-align:right'>&nbsp;&nbsp;" . $category['Name'] . "&nbsp;&nbsp;</td><td>&nbsp;&nbsp;" . $category['Count'] . "&nbsp;&nbsp;</td></tr>";
    }
    mysql_close($link);
    ?>

</table>

<br /><br />

Prior scrubbing and analysis of the data resulted in a slightly reduced dataset from the one originally downloaded from Yelp.
No raw data about individual reviews or reviews needed to be incorporated into the dashboard at runtime.  A summary of the
data that is available for runtime analysis within the dashboard is as follows.

<br /><br />

<table border='1'>

    <?php
    $link = mysql_connect($mysqlserver, $mysqlusername, $mysqlpassword)
        or die ("Error connecting to mysql server: ".mysql_error());

    $tables = mysql_query(
        "select 'Area' Name, count(*) Count from proximity_effects.Area where Name != 'Miscellaneous'
        union
        select 'Business', count(*) from proximity_effects.Business
        union
        select 'Business Category', count(*) from proximity_effects.Category;", $link);

    while ($table = mysql_fetch_assoc($tables)) {
        echo "<tr><td style='text-align:right'>&nbsp;&nbsp;" . $table['Name'] . "&nbsp;&nbsp;</td><td>&nbsp;&nbsp;" . $table['Count'] . " elements&nbsp;&nbsp;</td></tr>";
    }
    mysql_close($link);
    ?>

</table>

</div>
