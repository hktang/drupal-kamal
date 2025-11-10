<?php

/**
 * @file
 * Configuration file for the containerized Drupal site.
 *
 * When deployed as a Kamal managed container, the settings in
 * this file will override the default settings.php file.
 */

use Drupal\Core\Installer\InstallerKernel;

$redis_ready = !InstallerKernel::installationAttempted() && extension_loaded('redis') && class_exists('Drupal\redis\ClientFactory');

// Use Redis for caching on all environments, if the module is enabled.
// See documentation: https://project.pages.drupalcode.org/redis/
if ($redis_ready) {
  $settings['cache']['default'] = 'cache.backend.redis';
  $settings['container_yamls'][] = 'modules/contrib/redis/example.services.yml';
  $settings['container_yamls'][] = 'modules/contrib/redis/redis.services.yml';
  $settings['redis_compress_length'] = 100;
  $settings['redis_compress_level'] = 2;
  $settings['redis_invalidate_all_as_delete'] = TRUE;
  $settings['redis.connection']['host'] = 'nara-redis';  // Host name is auto-wired by Kamal.
  $settings['redis.connection']['port'] = 6379;
  $settings['redis.connection']['persistent'] = TRUE;
}

// // Disable all config splits by default.
// $config['config_split.config_split.local']['status'] = FALSE;
// $config['config_split.config_split.test']['status'] = FALSE;
// $config['config_split.config_split.live']['status'] = FALSE;
// $config['config_split.config_split.dev']['status'] = FALSE;

// // Reroute email for all environments by default.
// $config['reroute_email.settings']['enable'] = TRUE;
// $config['reroute_email.settings']['message'] = TRUE;
// $config['reroute_email.settings']['address'] = 'name@example.com';

// KAMAL_HOST is injected into the container by Kamal during build/deploy.
if (getenv('KAMAL_HOST')) {
  /*
   * With Kamal, we can manage environment variables during the container build
   * process, so we don't need to specify separate database credentials for each
   * environment. Instead, we use the env variables set in the config/deploy.yml
   * and .kamal/secret files (and their staging/development variations).
   */
  $databases['default']['default'] = [
    'database' => getenv('MYSQL_DATABASE'),
    'username' => getenv('MYSQL_USER'),
    'password' => getenv('MYSQL_PASSWORD'),
    'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
    'prefix' => '',
    'host' => getenv('MYSQL_HOST'),
    'port' => getenv('MYSQL_PORT'),
    'driver' => 'mysql',
  ];

  if ($redis_ready) {
    /*
     * Set a cache prefix based on the environment to prevent cache collision.
     * This is not necessary for prod as the host is different, but required
     * for dev and staging as they share the same host.
     */
    $settings['cache_prefix'] = 'nara_' . getenv('APP_ENV') . '_';
  }

  // switch (getenv('APP_ENV')) {
  //   case 'production':
  //     $config['config_split.config_split.live']['status'] = TRUE;
  //     $config['environment_indicator.indicator']['bg_color'] = '#EC0914';
  //     $config['environment_indicator.indicator']['name'] = 'PROD';
  //     $config['reroute_email.settings']['enable'] = FALSE;
  //     break;
  //
  //   case 'staging':
  //     $config['config_split.config_split.test']['status'] = TRUE;
  //     $config['environment_indicator.indicator']['bg_color'] = '#CA4B02';
  //     $config['environment_indicator.indicator']['name'] = 'STAGE';
  //     break;
  //
  //   case 'development':
  //     $config['config_split.config_split.dev']['status'] = TRUE;
  //     $config['environment_indicator.indicator']['bg_color'] = '#007FAD';
  //     $config['environment_indicator.indicator']['name'] = 'DEV';
  //     break;
  //
  //   default:
  //     $config['config_split.config_split.local']['status'] = TRUE;
  //     $config['environment_indicator.indicator']['bg_color'] = '#007A5A';
  //     $config['environment_indicator.indicator']['name'] = 'LOCAL';
  // }
}
