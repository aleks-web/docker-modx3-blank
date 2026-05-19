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

foreach ($renderFilesHash as $key => $file) {
    unset($renderFilesHash[$key]);
    $renderFilesHash[$file] = hash_file('sha256', $twPathRenderPath . '/' . $file);
}

if (!file_exists($twHashFile)) {
    file_put_contents($twHashFile, serialize($renderFilesHash));
}

if (!file_exists($twPath . '/node_modules')) {
    $command = 'cd ' . $twPath . ' && npm i';
    exec($command);
    return;
}

$hash = file_get_contents($twHashFile);

if ($hash === serialize($renderFilesHash)) {
    return;
}

exec('cd /var/www/modx/resources/assets/tw && npm run tw');
file_put_contents($twHashFile, serialize($renderFilesHash));