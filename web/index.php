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

    <br />
    <br />

    Do customer's expectations change in the presence of competition? In order to answer this question we user our Yelp dataset.
    
    <br />
    <br />

    An initial step in our analysis is to see if there is evidence for such effect. Regressing the original Yelp-star rating to distance between businesses from the same category reveals that our initial hypothesis is relevant and we need to investigate further.
    Before continuing and calculating the magnitude of the proximity effect, we need specific cleaning and standardizing the data. Our dataset is Likert, such that it represents users' preferences on a questionnaire scale. Analyzing it requires a specific methodology.
    
    <br />
    <br />
    <img border="0" src="images/likert.png" />
    <br />
    <br />

    Since every person have different perceptions, we cannot assume that 2-star rating for one reviewer means the same thing as for another Yelp user. Therefore, we need to average out, smooth and standardize the ratings. However, excluding the customers' bias has its peculiarities as well.
    The data that we have is of the type agree-disagree, meaning although there is "greater than" relation between both statements, it is not clear by how much. 
    Therefore, in order to standardize the rating for each user we look at their median and the absolute median deviation instead of the typical statistics - mean and standard deviation. For each user, we calculate new ratings based on their reviews given.  
    Subsequently, we re-estimate each business rating, using these adjusted user reviews. Since we do not have any additional information on the reviewers', this is the only way to control for the personality traits.

    <br />
    <br />
    <img border="0" src="images/inverse_distance_weighting.gif" />
    <br />
    <br />
    
    After removing this noise in the data, we control for population density. We take into account that density is not homogeneous in one district. However, the only population density data that is available is based on zip codes.
    Therefore, we calculate the density of each business by averaging the four closest zip-code densities.
    Having in mind what our Yelp data is, we can say that we have successfully controlled for the effect of consumer tastes and population density. Therefore, we can answer the question we have initially posed - is there proximity effect?
    If so, what is the magnitude? To illustrate, we take the standard deviation of each business in the same category in order to highlight the effect of ratings influence on increasing distance. In order to answer that, we control for distance in our regression. To conclude, it is observable  that evident proximity effect exists, however, further investigation and additional data are needed in order to clean the Yelp data from other biases.

</div>
