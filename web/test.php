<?php
$mysqlserver="localhost";
$mysqlusername="root";
$mysqlpassword="root";
?>

<script src="js/jquery-1.11.3.min.js" />

<script>
$(document).ready(function(){
    $("#ddlAreas").change(function () {

        // get the selected user's id
        //var id = $(this).find(":selected").val();

        // load it in the userInfo div above
        //$('#userInfo').load('data.php?id=' + id);
        var val = $(this).find(":selected").val();
        alert(val);
        $('#userInfo').load('data.php?id=' + id);
    });
});
</script>

<form method="get" action="http://www.yourwebskills.com/files/examples/process.php">

    <select id="ddlAreas" name="ddlAreas">
        <option id="-1">[Please select a city]</option>
        <?php
        $link=mysql_connect(localhost, $mysqlusername, $mysqlpassword)
            or die ("Error connecting to mysql server: ".mysql_error());        $areas = mysql_query("call proximity_effects.GetAllAreas();", $link);
        while ($area = mysql_fetch_assoc($areas)) {
            $name = $area['Name'] . " (" . $area['BusinessCount'] . ")";
            echo "<option value='" . $area['ID'] . "'>" . $name . "</option>";
        }
        mysql_close($link);
        ?>
    </select>

    <br />
    <br />

    <select id="ddlCategories" name="ddlCategories">
        <option id="-1">[Please select a category]</option>
        <?php
        $link=mysql_connect(localhost, $mysqlusername, $mysqlpassword)
            or die ("Error connecting to mysql server: ".mysql_error());        $categories = mysql_query("call proximity_effects.GetAllCategories();", $link);
        while ($category = mysql_fetch_assoc($categories)) {
            $name = $category['Name'];
            echo "<option value='" . $category['ID'] . "'>" . $name . "</option>";
        }
        mysql_close($link);
        ?>
    </select>

</form>
