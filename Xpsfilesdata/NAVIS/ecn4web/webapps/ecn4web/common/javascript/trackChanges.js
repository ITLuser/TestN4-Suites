/************************************************************************/
/**** Tracks changes for dirty forms and updates form buttons        ****/
/**** accordingly.                                                   ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** This file depends upon the following JavaScript files:         ****/
/****   -none                                                        ****/
/****                                                                ****/
/************************************************************************/

var dirtyForm = false;

function initForms()
{
	var curEl;
	
	if (is.ie && is.mac)
	{
		return;
	}
	for (var i=0; i<document.forms.length; i++)
	{
		if(document.forms[i].name == "searchForm")
		{
			continue;
		}
		for(j=0; j<document.forms[i].elements.length; j++)
		{
			curEl = document.forms[i].elements[j];
			if(is.ie)
			{
				if ((curEl.tagName == 'INPUT' || curEl.tagName == 'TEXTAREA' || curEl.tagName == 'SELECT') && curEl.className.indexOf("dontTrack") < 0)
				{
				  curEl.attachEvent('onkeyup', checkForChange);
				  if(curEl.type == "radio" || curEl.type == "checkbox")
				  {
					curEl.attachEvent('onclick', checkForChange);
					curEl.attachEvent('onkeyup', checkForChange);
				  }
				  if(curEl.tagName == "SELECT") curEl.attachEvent('onchange', checkForChange);
				} 
			}
			else
			{
				if ((curEl.tagName == 'INPUT' || curEl.tagName == 'TEXTAREA' || curEl.tagName == 'SELECT') && curEl.className.indexOf("dontTrack") < 0)
				{
				  curEl.addEventListener("keyup", checkForChange, false);
				  if(curEl.type == "radio" || curEl.type == "checkbox")
				  {
					curEl.addEventListener("click", checkForChange, false);
					curEl.addEventListener("keyup", checkForChange, false);
				  }
				  if(curEl.tagName == "SELECT") curEl.addEventListener("change", checkForChange, false);
				} 
			}
		}
	}
}

function releaseForms()
{
	if (is.ie && is.mac)
	{
		return;
	}
	for (var i=0; i<document.forms.length; i++)
	{
		if(document.forms[i].name == "searchForm")
		{
			continue;
		}
		for(j=0; j<document.forms[i].elements.length; j++)
		{
			curEl = document.forms[i].elements[j];
			if(is.ie)
			{
				if ((curEl.tagName == 'INPUT' || curEl.tagName == 'TEXTAREA' || curEl.tagName == 'SELECT') && curEl.className.indexOf("dontTrack") < 0)
				{
				  curEl.detachEvent('onkeyup', checkForChange);
				  if(curEl.type == "radio" || curEl.type == "checkbox") 
				  {
					curEl.detachEvent('onclick', checkForChange);
					curEl.detachEvent('onkeyup', checkForChange);
				  }
				  if(curEl.tagName == "SELECT") curEl.detachEvent('onchange', checkForChange);
				} 
			}
			else
			{
				if ((curEl.tagName == 'INPUT' || curEl.tagName == 'TEXTAREA' || curEl.tagName == 'SELECT') && curEl.className.indexOf("dontTrack") < 0)
				{
				  curEl.removeEventListener("keyup", checkForChange, false);
				  if(curEl.type == "radio" || curEl.type == "checkbox") 
				  {
					curEl.removeEventListener("click", checkForChange, false);
					curEl.removeEventListener("keyup", checkForChange, false);
				  }
				  if(curEl.tagName == "SELECT") curEl.removeEventListener("change", checkForChange, false);
				} 
			}
		}
	}
}

function checkForChange(e)
{
	var curInput = getSrcElement(e);
	if(curInput.defaultValue != curInput.value)
	{
		alert('change')
	}
}
