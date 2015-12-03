
/**
 * Given an element, or an element ID, blank its style's display
 * property (return it to default)
 */
function show(element) {
    if (typeof(element) != "object")	{
        element = document.getElementById(element);
    }

    if (typeof(element) == "object") {
        element.style.display = '';
    }
}

/**
 * Given an element, or an element ID, set its style's display property
 * to 'none'
 */
function hide(element) {
    if (typeof(element) != "object")	{
        element = document.getElementById(element);
    }

    if (typeof(element) == "object") {
        element.style.display = 'none';
    }
}

function show_content(optionsId) {
    var ids = new Array('home','data','analysis');
    show(optionsId);
    document.getElementById(optionsId + '_link').className = 'active';

    for (var i = 0; i < ids.length; i++)
    {
        if (ids[i] == optionsId) continue;
        hide(ids[i]);
        document.getElementById(ids[i] + '_link').className = '';
    }
}
