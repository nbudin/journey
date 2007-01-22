function checkAll(name)
{
  boxes = document.getElementsByName(name)
  for (i = 0; i < boxes.length; i++)
        boxes[i].checked = true ;
}

function uncheckAll(name)
{
  boxes = document.getElementsByName(name)
  for (i = 0; i < boxes.length; i++)
        boxes[i].checked = false ;
}