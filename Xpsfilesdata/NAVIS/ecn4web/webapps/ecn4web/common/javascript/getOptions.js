/*
*
* Copyright Navis Corporation 2003
* All Rights Reserved
*
* Confidential Information of Navis Corporation
* Unauthorized use is strictly prohibited
*
* This work contains valuable confidential proprietary trade secret
* information of Navis Corporation and is protected by specific
* agreements and federal copyright. This work or any part thereof
* may not be disclosed, transmitted, copied, or reproduced in any
* form or medium without prior written authorization from Navis
* Corporation.
*/

/*
* getOptions fills LOVs based on multi-dimensional arrays defined on
* a given HTML page.
*
*/

/*
* TO DO:
*   None.
*/

/*
* IMPLEMENTATION NOTES:
* Parameters:
*   See notes below.
*
*   Define the parent and dependent multi-dimensional Arrays:
*       var pOptArray1 = [
*       ['value1', 'text1'],
*       ['value2', 'text2']
*       ...
*       ]
*       var dOptArray1 = [
*       ['[key:parent value1]','value1','text1'],
*       ['[key:parent value1]','value2','text2'],
*       ['[key:parent value1]','value3','text3'],
*       ['[key:parent value1]','value4','text4'],
*       ['[key:parent value2]','value5','text5'],
*       ['[key:parent value2]','value6','text6'],
*       ['[key:parent value2]','value7','text7'],
*       ['[key:parent value2]','value8','text8']
*       ...
*       ]
*   Create a new LinkedSet and attach it to the LinkedOptions Object:
*       LinkedOptions['lO1'] = new LinkedSet('lO1');
*       LinkedOptions['lO1'].pOpts = pOptArray1;
*       LinkedOptions['lO1'].dOpts = dOptArray1;
*
*   Link the "parent" LOV to a dependent and define the 
*   LinkedOptions (LinkedSet) by adding the following EXPANDO
*   attributes:
*       dependent="toThis"
*       lovOptionObject="lO1"
*
* Requires:
*   lovHandlers.js
*   autocomplete.js
*
*/

/************************************************************************
***** GLOBAL VARIABLES                                               ****
************************************************************************/

var LinkedOptions = new Object();

/************************************************************************
***** CONSTRUCTORS                                                   ****
************************************************************************/

function LinkedSet(id)
{
  this.id = id;
  this.pOpts;
  this.dOpts;
}

/************************************************************************
***** FUNCTIONS                                                      ****
************************************************************************/


function lovSetOptionsParent()
{
  var newOpt;
  var parentOptArray = LinkedOptions[this.inputObj.getAttribute('lovOptionObject')].pOpts;
  // add initial option
  //obj.options[obj.length] = defaultOpt;
  for(var i=0;i<parentOptArray.length;i++)
  {
    if(parentOptArray[i])
    {
      newOpt = new Option(parentOptArray[i][1] , parentOptArray[i][0]);
    }
    this.selectObj.options[this.selectObj.options.length] = newOpt;
    this.selectObj.selectedIndex = -1;
  }
}

function reSetOptions(obj)
{
  removeOptions(obj);
  getOpts(obj);
}

function removeOptions(obj)
{
  var dependentId = obj.getAttribute('dependent')
  var from = getLov(dependentId).selectObj
  var lInput = getLov(dependentId).inputObj;
  var dOptArray = LinkedOptions[getLov(obj.id).selectObj.getAttribute('lovOptionObject')].dOpts;
  
  from.options.length = 0; // remove all options
  // set the LOV input value to valueStr
  lInput.value = dOptArray[0][2];
  initLov(from.id)
}

function hasMapping(pObj,dependentId)
{
  var dOptArray = LinkedOptions[getLov(pObj.id).selectObj.getAttribute('lovOptionObject')].dOpts;
 
  for(var k=0;k<dOptArray.length;k++)
  {
    if(dOptArray[k][0] == pObj.value)
    {
      return true;
    }
  }
  return false;
}

function getOpts(obj)
{
  var newOpt;
  var dependentId = obj.getAttribute('dependent');
  var opts = new Array();
  var to = getLov(dependentId).selectObj; // grab the selectObj
  var lInput = getLov(dependentId).inputObj; // grab the inputObj
  var lButton = getLov(dependentId).buttonObjImg; // grab the buttonObjImg
  var dOptArray = LinkedOptions[getLov(obj.id).selectObj.getAttribute('lovOptionObject')].dOpts;
  
  if(hasMapping(obj)) // test if there is a match, if so proceed
  {
    to.disabled = false;
    // set the LOV input to not disabled
    lInput.disabled = false;
    // set the button src
    lButton.src = defaultLovButtonSrc;
    for(var j=0;j<dOptArray.length;j++)
    {
      if(dOptArray[j][0] == obj.value)
      {
        opts[opts.length] = dOptArray[j]
      }
    }
    for(var i=0;i<opts.length;i++)
    {
      newOpt = new Option(opts[i][2] , opts[i][1]);
      to.options[to.length] = newOpt;
      initLov(to.id)
      to.selectedIndex = 0;
    } 
  }
  else // if no match, disable the dependent
  {
    var defaultOpt = new Option(dOptArray[0][2] , dOptArray[0][1]); // define initial option  
  
    to.options[0] = defaultOpt;
    to.disabled = true;
    // set the LOV input to disabled
    lInput.disabled = true;
    // set the button src
    lButton.src = defaultLovButtonDisabledSrc;
    initLov(to.id)
  }
}
