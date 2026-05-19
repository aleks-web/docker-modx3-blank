<?php
if ($modx->event->name !== 'OnWebPagePrerender') {
    return;
}

$twPath = $modx->config['base_path'] . 'resources/assets/tw';
$twHashFile = $twPath . '/hash.txt';
$twPathRenderPath = $twPath . '/render_pages';
$renderFilesHash = array_values(array_diff(scandir( $twPathRenderPath), array('..', '.')));
$output = &$modx->resource->_output;
$renderFileName = 'page-' . $modx->resource->id . '.html';
$renderFilePath = $twPath . '/render_pages/' . $renderFileName;

file_put_contents($renderFilePath, $output);

if (file_exists($twHashFile)) {
    unlink($twHashFile);
}

if (!file_exists($twPath . '/node_modules')) {
    $command = 'cd ' . $twPath . ' && npm i';
    exec($command);
    return;
}