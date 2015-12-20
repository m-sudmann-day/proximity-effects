<title>Proximity Effects on Customer Sentiment</title>
<link rel="stylesheet" type="text/css" href="style.css" />
<script src="js/navbar.js" type="text/javascript"></script>

<div id="header"><h1>Proximity Effects on Customer Sentiment</h1></div>


<div id="menu">
    <a id="home_link" href="index.php" class="active" onclick="show_content('home'); return false;">Home</a> &middot;
    <a id="data_link" href="data.php" onclick="show_content('data'); return false;">Data</a> &middot;
    <a id="analysis_link" href="analysis.php" onclick="show_content('analysis'); return false;">Analysis</a>
</div>

<div id="main" style="width:99%; margin:0px; padding:0px; font-size:16; margin-left:30px; margin-right:30px">

    <br /><br />

    Does consumer sentiment change in the presence of local competition? In order to answer this question, we turned to a publicly available dataset from the business review site Yelp.com.

    <br /><br />

    Yelp published approximately ten years of customer reviews for businesses within 10 geographies spanning four countries, 61,000 businesses, 366,000 reviewers, and 1.6 million individual reviews.  Each business was attributed to one or more of about 1,000 business categories.

    <br /><br />
    
    Additionally, for the US-based businesses, we obtained population density information from the US Census Bureau and used inverse distance weighting to calculate specific population density estimates for each individual business allowing us to adjust for population density in our distance calculations for those cities.  The inverse distance weighting method we used is documented here, but for a quick understanding, the diagram and equation below show how values are averaged together, giving more weight to those with less distance:
    
    <br /><br />
    
    <img border="0" src="images/inverse_distance_weighting.gif" />

    <br /><br />

    Yelp ratings follow the format of typical “star ratings”; reviewers can select a round number of stars from one to five.  Recognizing that these scores are more appropriately treated as ordered categories than actual numbers, we turned to the Likert scale.  The Likert scale interprets questionnaire-style categories such as the following:

    <br /><br />

    <img border="0" src="images/likert.png" />

    <br /><br />

    The categories in this data have different meanings to different people so the Likert scale avoids attempting to quantify them directly.  For this reason, centrality is better identified by the median than the mean, and deviation is better identified by absolute deviation than standard deviation.

    <br /><br />

    Subsequently, we standardized the ratings of every individual review against the distribution of ratings by the corresponding reviewer.  This gave us a median of 0 with an absolute deviation of 1 for every business review against the behavior of the specific reviewer.  Then we averaged those standardized ratings to obtain new ratings for each individual business on the same scale.

    <br /><br />

    To conclude, our results vary in magnitude, direction, and significance between business categories, and to a lesser extent, between geographical areas.  Many of the category/area combinations have too few businesses to draw statistical conclusions, but many also have plenty.  The Data tab gives a high-level summary of the data available.  The Analysis tab is to enable the user to explore specific categories and geographical areas to visualize these effects and draw their own conclusions.

    <br /><br />
    
    <img border="0" src="images/inverse_distance_weighting.gif" />
    
    <br /><br />
    
    After removing this noise in the data, we control for population density. We take into account that density is not homogeneous in one district. However, the only population density data that is available is based on zip codes.
    Therefore, we calculate the density of each business by averaging the four closest zip-code densities.
    Having in mind what our Yelp data is, we can say that we have successfully controlled for the effect of consumer tastes and population density. Therefore, we can answer the question we have initially posed - is there proximity effect?
    If so, what is the magnitude? To illustrate, we take the standard deviation of each business in the same category in order to highlight the effect of ratings influence on increasing distance. In order to answer that, we control for distance in our regression. To conclude, it is observable  that evident proximity effect exists, however, further investigation and additional data are needed in order to clean the Yelp data from other biases.

</div>
