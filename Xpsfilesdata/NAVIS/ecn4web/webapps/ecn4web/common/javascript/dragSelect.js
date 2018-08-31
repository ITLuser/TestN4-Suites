/**
 * This javascript patch is from ZK support for the support incident https://potix.freshdesk.com/helpdesk/tickets/2478
 * ZK engineer: Matthieu Duchemin
 *
 */
function getRowContaining(target,container){
    if (!target || !container || target.hasClass('z-listbox-body') || target.size() == 0 || container.$n().contains(target[0]) == -1)
        return null;
    if (target.hasClass('z-listitem')){
        return target;
    } else {
        return getRowContaining(target.parent(),container);
    }
}

$.getScript("common/javascript/jquery-ui.min.js").done(function(data, textStatus, jqxhr) {
    document.initSelectComp = function (comp){
        jq(comp).draggable({
            start: function(event) {
                document._initDragSelection = zk(this).$()._index;
                document._lastDragSelection = zk(this).$()._index;
                document._currentRowHeight = zk(this).$().$n().clientHeight;
                document._currentDragListbox = zk(this).$().parent;
                document._lastSelection = document._currentDragListbox.getSelectedItems();
                document._currentCtrlKey = event.ctrlKey;
                document._doDragSelect = true;
                if(event.ctrlKey == true){
                    document._doDragSelect = !zk(this).$().isSelected();
                }else{
                    document._currentDragListbox.clearSelection();
                }
                zk(this).$().setSelected(document._doDragSelect);
            },
            drag: function(event, ui) {
                var initIndex = document._initDragSelection;
                var lastIndex = document._lastDragSelection;
                if(event.originalEvent && zk(document._currentDragListbox).$().$n().contains(event.originalEvent.target)){
                    var thisRow = zk(getRowContaining(jq(event.originalEvent.target), document._currentDragListbox)).$();
                    var thisIndex = null;
                    if (thisRow != null)
                        var thisIndex = zk(thisRow).$()._index;
                    if(thisIndex != null){
                        document._currentDragListbox.clearSelection();
                        if(document._currentCtrlKey){
                            document._lastSelection.forEach(function(item){
                                if(item){
                                    item.setSelected(true);
                                }
                            });
                        }
                        if(thisIndex == initIndex){
                            zk(this).$().setSelected(document._doDragSelect);
                        }
                        minIndex = Math.min(thisIndex,initIndex);
                        maxIndex = Math.max(thisIndex,initIndex);
                        document._lastDragSelection = zk(thisRow).$()._index;
                        for(i=0; i<=document._currentDragListbox.nChildren; i++){
                            thisChild = document._currentDragListbox.getChildAt(i)
                            if(jq(thisChild).hasClass("z-listitem-focus"))
                                jq(thisChild).removeClass("z-listitem-focus")
                            if(thisChild && thisChild._index >= minIndex && thisChild._index<=maxIndex)
                                thisChild.setSelected(document._doDragSelect);
                        }
                    }

                }else{
                    var direction = (lastIndex - initIndex > 0)? 1 : -1;
                    for(i=0; i<=document._currentDragListbox.nChildren; i++){
                        thisChild = document._currentDragListbox.getChildAt(i)
                        if(thisChild && ((thisChild._index-initIndex)*direction >= 0))
                            thisChild.setSelected(document._doDragSelect);
                    }
                }
            },
            stop: function(event) {
                if(event){
                    var initIndex = document._initDragSelection;
                    var lastIndex = document._lastDragSelection;
                    var data = {};
                    data['start'] = document._initDragSelection;
                    data['doDragSelect'] = document._doDragSelect;
                    data['ctrlKey'] = (document._currentCtrlKey)? true : false;
                    var isDirectionDown = (lastIndex - initIndex > 0)? 1 : 0;
                    if(zk(document._currentDragListbox).$().$n().contains(event.originalEvent.target)){
                        data['end'] = document._lastDragSelection;
                    }else{
                        var lastDisplayedRow = (Math.floor((document._currentDragListbox.$n().clientHeight * isDirectionDown + jq(document._currentDragListbox)[0].getElementsByClassName("z-listbox-body")[0].scrollTop)/document._currentRowHeight));
                        data['end'] = Math.min(lastDisplayedRow,document._currentDragListbox._totalSize-1 )
                    }
                    document._currentDragListbox.fire("onDragSelect",data,{toServer:true});
                }
            },
            containment: "window",
            helper: function( event ) {
                return $("<div></div>");
            }
        });
    }
});

/**
 * Adds effect to draggable component such as
 * 1. Highlighting drop zone on dragging a floating window towards the top
 * 2. Adding dummy  tab to indicate the user where the tab is going to be inserted
 * 3. clearing global variables and events used to have the effect
 *
 */

var draggingEffect = {
  
    _attachOnMouseUpEvent: function (inElem) {
        if (inElem != null) {
            inElem.onmouseup = function () {
                draggingEffect._removeHoveredTabStyle();
                //When rearranging tabs send event to server to handle the onDrop of the target component upon releasing the mouse.
                if (rearrangingTab) {
                    var tabView = (zk.Widget.$('$tabView'));
                    rearrangingTab = false;
                    zAu.send(new zk.Event(tabView, 'onUser', null, {toServer: true}));
                }
                inElem.onmouseup = null;
                return false;
            };
        }
    },
    //attaches onmousedown event to a tab. To be called from server side
    _attachOnMouseDownEvent: function (inUuid) {
        var inElem = zk.Widget.$("#" + inUuid.id);
        if (inElem != null && inElem._node != null) {
            inElem._node.onmousedown = function (evt) {
                if (!evt) {
                    evt = window.Event;
                }
                //get the original mouse position and left most offset of the floating window
                originalMouseXPos = (evt.pageX) ? evt.pageX : evt.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
                originalLeftOffset = jq(inElem).offset().left;
                mousePositionToLeftOffsetDiff = originalMouseXPos - originalLeftOffset;
                return false;
            }
        }
    },

    _removeHoveredTabStyle: function () {
        //remove dummy tabs inserted
        var dummyTabs = document.getElementsByClassName('insert_tab z-tab');
        while (dummyTabs[0]) {
            dummyTabs[0].parentNode.removeChild(dummyTabs[0]);
        }
    }

};
//global variables to determine the left most offset of the floating window

var originalMouseXPos = 0;
var originalLeftOffset = 0;
var mousePositionToLeftOffsetDiff = 0;
var rearrangingTab = false;

/**
 * An algorithm to add special effects on dragging Tab and floating windows
 */
zk.afterLoad('zk', function () {

    var xDraggable = {};

    zk.afterLoad('zk', function () {

        var xDraggable = {};

        zk.override(zk.Draggable.prototype, xDraggable, {
            _updateDrag: function (pt, evt) {
                var currentTarget = evt.currentTarget;
                if (currentTarget != null) {
                    //we are restricting having the drag effect only for the draggable components
                    var target = currentTarget._node;
                        var tabboxWgt = zk.Widget.$('$tabbox');
                    if (target != null && tabboxWgt!=null) {
                        var tabbox = tabboxWgt._node;
                        if (tabbox != null) {
                            if (!evt) {
                                evt = window.Event;
                            }
                            var currentMouseYPos = (evt.pageY) ? evt.pageY : evt.clientY;
                            var currentMouseXPos = (evt.pageX) ? evt.pageX :
                                    evt.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
                            var tabsTopMost = tabbox.offsetTop;
                            var targetLeftOffset = currentMouseXPos - mousePositionToLeftOffsetDiff;
                            //if dragging the element towards the tab view's top apply special dragging effects
                            if (Math.abs(currentMouseYPos - tabsTopMost) <= 35) {
                                var draggingTab = hasClass(target, "z-tab");

                                if (hasClass(target, 'floating_tab') || draggingTab) {
                                    var dummy_li = getDummyTab();
                                    var tabs = (zk.Widget.$('$tabs'))._node;
                                    if (tabs != null) {
                                        var tabList = (tabs.firstChild).children;
                                        var data = {};
                                        var tabs_ul = tabs.firstChild;
                                        if(tabList.length==0){
                                              tabs_ul.appendChild(dummy_li);
                                            return;
                                        }
                                        for (var i = 0; i < tabList.length; i++) {
                                            draggingEffect._removeHoveredTabStyle();
                                            var tab = tabList[i];
                                            if(tab==null || tab.id=="dummy_tab"){
                                                continue;
                                            }
                                            var tabLeftMost = (tab.offsetLeft - (tab.scrollLeft + tab.clientLeft));
                                            var tabWidth = tab.offsetWidth;

                                            //if dragged element left most edge is between the current tab's width
                                            if (currentMouseXPos >= tabLeftMost && currentMouseXPos <= tabWidth + tabLeftMost) {
                                                data['droppedOverTabId'] = tab.id;
                                                //if dragging another tab while doing rearrange send the dragged tab and dragged over tab to server
                                                if (draggingTab && this.node != null) {
                                                    var draggedTabId = this.node.id;
                                                    //if the dragged tab id can't be determined(ghost element) check the first element of the ghost
                                                    if (draggedTabId == "zk_ddghost" && this.node.firstChild != null) {
                                                        var ghostId = this.node.firstChild.id;
                                                        if (ghostId != null && ghostId.indexOf("-cave") > -1) {
                                                            draggedTabId = ghostId.substring(0, ghostId.length - 5);
                                                        }
                                                    }
                                                    data['draggedTabId'] = draggedTabId;
                                                    data['droppedOverTabId'] = tab.id;
                                                    zAu.send(new zk.Event(currentTarget, 'onUser', data, {toServer: true}));
                                                    tabs_ul.insertBefore(dummy_li, tabList[i]);
                                                    rearrangingTab = true;
                                                    break;
                                                }

                                                else {
                                                    //dropping floating window
                                                    // console.log("Sending over tab id=",tab.id);
                                                    data['droppedOverTabId'] = tab.id;                                                                  zAu.send(new zk.Event(currentTarget, 'onUser', data, {toServer: true}));
                                                    tabs_ul.insertBefore(dummy_li, tabList[i]);
                                                    break;

                                                }

                                            }
                                            if (i == tabList.length - 1 ) {
                                                if(!draggingTab){
                                                data['droppedOverTabId'] = null;
                                                zAu.send(new zk.Event(currentTarget, 'onUser', data, {toServer: true}));
                                                }
                                                tabs_ul.appendChild(getDummyTab());
                                               break;

                                            }
                                            draggingEffect._removeHoveredTabStyle();

                                        }
                                    }

                                }
                            }
                            else{
                                 draggingEffect._removeHoveredTabStyle();
                            }

                        }
                        draggingEffect._attachOnMouseUpEvent(evt.domTarget);
                    }

                }
                var result = xDraggable._updateDrag.apply(this, arguments);
                return result;
            }
        });
    });
});

function hasClass(elem, klass) {
    return (" " + elem.className + " " ).indexOf(" " + klass + " ") > -1;
}
//create the dummy tab
function getDummyTab() {
    var el_li = document.createElement('li');
    el_li.setAttribute('id', 'dummy_tab');
    el_li.setAttribute('class', 'insert_tab z-tab');

    var el_a = document.createElement('a');
    el_a.setAttribute('id', 'dummy_tab_cave');
    el_a.setAttribute('class', 'z-tab-content');

    var el_span = document.createElement("span");
    el_span.innerHTML = "&nbsp;&nbsp;";
    el_span.setAttribute('class', 'z-tab-text');
    el_span.setAttribute('style', 'padding-left:20px')

    el_a.appendChild(el_span);
    el_li.appendChild(el_a);

    return el_li;

}







