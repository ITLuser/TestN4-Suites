function sortie(tableSort){

	var tableRows = tableSort.getElementsByTagName("tr");
	var columns = tableSort.querySelectorAll("tr th");
	var tableCells = tableSort.getElementsByTagName("td");
	var rowsTable = new Array();
	var sorted = ["up",0];

	for (var i = 0; i < tableRows.length; i++) {
		if(i%2==0){
		tableRows[i].className = "even";
		}else{
		tableRows[i].className = "odd";
		}
	}

	var disabled = new Array();

	for (var k = 0; k < columns.length; k++){
		disabled[k]=columns[k].getAttribute("disabled");
	}

	for (var z = 0; z < columns.length; z++){
		if(disabled[z] == "true") continue;
		var currentCol = z;
		columns[currentCol].onclick=(function(currentCol){
			return function() {

				if(sorted[0] == "up"){
					sortDown(currentCol);
				}else{
					sortUp(currentCol);
				}
				return false;
			};
		})(currentCol);
	}


	for (var i = 0; i < tableRows.length; i++) {
			rowsTable[i] = new Array(columns.length-1);
	}




	for (var i = 0; i < tableRows.length-1; i++) {
		 for (var j = i * (columns.length), k = 0; j < ((i * (columns.length))+3), k < columns.length; j++, k++){
			rowsTable[i][k] = tableCells[j].innerHTML;
		 }
	}


	var begin_sort=tableSort.getAttribute("begin_sort") || "NaN";
	var start_column=tableSort.getAttribute("start_column") || 1;

	if(begin_sort == "ascending"){
		if(disabled[start_column - 1] == "true") return true;
		sortUp(start_column - 1);
	}else if(begin_sort == "descending"){
		if(disabled[start_column - 1] == "true") return true;
		sortDown(start_column - 1);
	}

	function printTable(){
		for (var i = 0; i < tableRows.length-1; i++) {
			 for (var j = i*columns.length, k = 0; j < tableCells.length-1, k < columns.length; j++, k++){
				if(disabled[k] == "true") continue;
				 tableCells[j].innerHTML = rowsTable[i][k];
			 }
		}
	}

	function sortUp(rowNum){
		  if(isNaN(rowsTable[0][rowNum]) == true){
			rowsTable.sort(function(a, b) {
				var avalue = a[rowNum],
					bvalue = b[rowNum];
				if (avalue < bvalue) {
					return -1;
				}
				if (avalue > bvalue) {
					return 1;
				}
				return 0;
			});
		  }else{
			rowsTable.sort(function(a, b) {
				var avalue = parseFloat(a[rowNum]),
					bvalue = parseFloat(b[rowNum]);
				if (avalue < bvalue) {
					return -1;
				}
				if (avalue > bvalue) {
					return 1;
				}
				return 0;
			});
		  }
		printTable();
		sorted = ["up",rowNum];
	}



	function sortDown(rowNum){
		  if(isNaN(rowsTable[0][rowNum]) == true){
			rowsTable.sort(function(a, b) {
				var avalue = a[rowNum],
					bvalue = b[rowNum];
				if (avalue > bvalue) {
					return -1;
				}
				if (avalue < bvalue) {
					return 1;
				}
				return 0;
			});
		  }else{
			rowsTable.sort(function(a, b) {
				var avalue = parseFloat(a[rowNum]),
					bvalue = parseFloat(b[rowNum]);
				if (avalue > bvalue) {
					return -1;
				}
				if (avalue < bvalue) {
					return 1;
				}
				return 0;
			});
		  }
		printTable();
		sorted = ["down",rowNum];
	}
}
