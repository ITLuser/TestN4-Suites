var timer = document.getElementById('timerParent');
var field = document.getElementById('fieldParent');
var checkButton = document.getElementById('ftButtonNoError');
var errorButton = document.getElementById('ftButtonError');
var j = 0;
var on = false;
var hasError = false;
var errMssg = 'There has been an error. This is where the error would be described.';
var ttMssg = 'Enter a PO Number into the field and click here to pull up that PO.';

function watchTimer(){
if(j>=timerDivs.length){
	j = 0;
}
if(on == false){ return }
		if(timerDivs[j].className == 'filler m'){
			timerDivs[j].className = 'filler l';
		}

		else{
			timerDivs[j].className = 'filler m';
		}
j++

setTimeout("watchTimer()", 100)
}

function startTimer(){
		on = true;
		hide('ftButtonNoError');
		hide('ftButtonError');
		hide('fieldParent')
		show('timerParent')
		watchTimer();
}

function stopTimer(){
for(i=0; i<timerDivs.length;i++){
	timerDivs[i].className = 'filler l';
}
		j = 0;
		on = false;
		hide('timerParent')
		show('fieldParent')
}

var timerDivs = new Array();

function watchElements(){
divs = document.getElementsByTagName('div');
		for(i=0;i<divs.length;i++){
//		alert(divs[i].parentNode.id)
			if(divs[i].parentNode.id == 'timerParent'){
				timerDivs.push(divs[i])
			}
		}
}

function initFieldTest(){
	stopTimer();
	if(hasError == true){
		hide('ftButtonNoError');
		show('ftButtonError');
	}
	else{
		hide('ftButtonError')
		show('ftButtonNoError')
	}
}

function resetError(){
		hasError = false;
		initFieldTest()
}