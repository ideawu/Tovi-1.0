<?php
$a = file_get_contents('jquery-1.9.1.js');
$b = file_get_contents('tovi.js');
$tovi_js = "<script>$a; $b</script>";

$html = file_get_contents('tovi.html');
$html = str_replace('<script type="text/javascript" src="jquery-1.9.1.js"></script>', '', $html);
$html = str_replace('<script type="text/javascript" src="tovi.js"></script>', $tovi_js, $html);

$html = str_replace('\\', '\\\\', $html);
$html = str_replace(array("\r", "\n", "\""), array('', '\n', '\\"'), $html);

$html = "NSString *tovi_html = @\"$html\";\n";
file_put_contents('../Tovi/Tovi/tovi.h', $html);

$cmd = "
cp -r swipe.js themes images ../Tovi/tovi-js/
";
system($cmd);

