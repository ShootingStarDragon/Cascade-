; List all processes
$list = ProcessList()
for $i = 1 to $list[0][0]
  msgbox(0, $list[$i][0], $list[$i][0])
next