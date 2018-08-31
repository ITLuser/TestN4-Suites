function mod(divisee,base) {
	return Math.round(divisee - (Math.floor(divisee/base)*base));
}

function isEven(x)
{ 
  return (x%2)?true:false;
}

function isOdd(x)
{
  return !isEven(x);
}
