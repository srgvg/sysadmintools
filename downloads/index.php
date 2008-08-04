<?php

// PHP 4.0.3

include_once(dirname(__FILE__) . '/config.inc.php');


if (isset($_FILES['upload'])) {

$uid = md5(uniqid(rand(), true));
$upload_path .= $uid . '/';

mkdir($upload_path);
chmod($upload_path, $file_mask);

$file = str_replace(' ', '_', basename( $_FILES['upload']['name']));

/* Upload */

$target_file = $upload_path . $file;

if(move_uploaded_file($_FILES['upload']['tmp_name'], $target_file)) {

$msg = 'Upload successful';
chmod($target_file, $file_mask); /* cannot be writable */

$download_url = $download_root . $uid . '/' . $file;

$msg = "Download link:<br /> <textarea rows='5' cols='60'>{$download_url}</textarea> <p>Copy this link into an email or other medium.</p>";

} else{
$msg = 'There was an error uploading the file.';
}

}

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Ginsys File Upload</title>

    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link rel="stylesheet" type="text/css" href="style.css" />
</head>
<body>

<h1>Ginsys File Upload</h1>

<form enctype="multipart/form-data" action="<?= $_SERVER['PHP_SELF'] ?>" method="POST" onsubmit="if(this.recipient.value == '') { alert('Recipient is required.'); return false; }">
<table>
<tr>
    <td>Choose a file to upload:</td>
    <td><input name="upload" type="file" /></td>
</tr>
<tr>
    <td colspan="2" align="right"><input type="submit" value="Upload File" /></td>
</tr>
</table>
</form>

<?php if (isset($msg)): ?>
<p class="msg"><?= $msg ?></p>
<?php endif; ?>

</body>
</html>
