<?php

require_once 'config.core.php';
require_once MODX_CORE_PATH . 'vendor/autoload.php';
$modx = new \MODX\Revolution\modX();
$modx->initialize('mgr');


try {
    // Upload_files setting
    $objUploadFiles = $modx->getObject('modSystemSetting', ['key' => 'upload_files']);
    $data_upload_files = explode(',', $objUploadFiles->get('value'));

    if (!in_array('php', $data_upload_files)) {
        array_push($data_upload_files, 'php');
    }

    if (!in_array('json', $data_upload_files)) {
        array_push($data_upload_files, 'json');
    }

    if (!in_array('htaccess', $data_upload_files)) {
        array_push($data_upload_files, 'htaccess');
    }

    $data_upload_files = implode(',', $data_upload_files);
    $objUploadFiles->set('value', $data_upload_files);
    $objUploadFiles->save();

    // Proxy Settings
    $objProxyHost = $modx->getObject('modSystemSetting', ['key' => 'proxy_host']);
    $objProxyHost->set('value', '138.124.21.47');
    $objProxyHost->save();

    $objProxyPassword = $modx->getObject('modSystemSetting', ['key' => 'proxy_password']);
    $objProxyPassword->set('value', 'f5z9sd');
    $objProxyPassword->save();

    $objProxyProt = $modx->getObject('modSystemSetting', ['key' => 'proxy_port']);
    $objProxyProt->set('value', '2786');
    $objProxyProt->save();

    $objProxyUserName = $modx->getObject('modSystemSetting', ['key' => 'proxy_username']);
    $objProxyUserName->set('value', 'user406350');
    $objProxyUserName->save();

    // Создание источников
    function createMediaResources(&$modx) {
        $props = array(
            'basePath' => 'resources/',
            'basePathRelative' => array(
                'name' => 'basePathRelative',
                'desc' => 'prop_file.basePathRelative_desc',
                'type' => 'combo-boolean',
                'value' => 1,
                'lexicon' => 'core:source'
            ),
            'baseUrl' => 'resources/',
            'baseUrlRelative' => array(
                'name' => 'basePathRelative',
                'desc' => 'prop_file.baseUrlRelative_desc',
                'type' => 'combo-boolean',
                'value' => 1,
                'lexicon' => 'core:source'
            ),
        );

        $obj = $modx->newObject('MODX\Revolution\Sources\\modMediaSource');
        $obj->set('name', 'Resources');
        $obj->set('description', 'Ресурсы сайта');
        $obj->setProperties($props);
        $obj->save();

        return $obj;
    };
    $mediaResorcesObj = createMediaResources($modx);

    function createMediaUploads(&$modx) {
        $props = array(
            'basePath' => 'uploads/',
            'basePathRelative' => array(
                'name' => 'basePathRelative',
                'desc' => 'prop_file.basePathRelative_desc',
                'type' => 'combo-boolean',
                'value' => 1,
                'lexicon' => 'core:source'
            ),
            'baseUrl' => 'uploads/',
            'baseUrlRelative' => array(
                'name' => 'basePathRelative',
                'desc' => 'prop_file.baseUrlRelative_desc',
                'type' => 'combo-boolean',
                'value' => 1,
                'lexicon' => 'core:source'
            ),
        );

        $obj = $modx->newObject('MODX\Revolution\Sources\\modMediaSource');
        $obj->set('name', 'Uploads');
        $obj->set('description', 'Медиа сайта');
        $obj->setProperties($props);
        $obj->save();

        return $obj;
    };
    $mediaUploadsObj = createMediaUploads($modx);

    echo 'config_settins.php системные настройки обновлены' . "\n";
} catch (\Exception $e) {
    echo 'config_settins.php системные настройки не обновлены' . "\n";
}