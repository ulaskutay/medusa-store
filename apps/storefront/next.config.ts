import type { NextConfig } from 'next';
import path from 'path';
import { createRequire } from 'module';

const require = createRequire(import.meta.url);
const checkEnvVariables = require('./check-env-variables');

checkEnvVariables();

const S3_HOSTNAME = process.env.MEDUSA_CLOUD_S3_HOSTNAME;
const S3_PATHNAME = process.env.MEDUSA_CLOUD_S3_PATHNAME;

function resolvePackageDir(pkg: string): string {
  try {
    return path.dirname(require.resolve(`${pkg}/package.json`, { paths: [__dirname] }));
  } catch {
    return path.resolve(__dirname, '../../node_modules', pkg);
  }
}

function getReactAliases() {
  const reactDir = resolvePackageDir('react');
  const reactDomDir = resolvePackageDir('react-dom');

  return {
    react: reactDir,
    'react-dom': reactDomDir,
    'react-dom/client': path.join(reactDomDir, 'client.js'),
    'react-dom/server': path.join(reactDomDir, 'server.browser.js'),
    'react/jsx-runtime': path.join(reactDir, 'jsx-runtime.js'),
    'react/jsx-dev-runtime': path.join(reactDir, 'jsx-dev-runtime.js')
  };
}

const nextConfig: NextConfig = {
  output: 'standalone',
  outputFileTracingRoot: path.join(__dirname, '../..'),
  transpilePackages: ['@medusajs/ui'],
  trailingSlash: false,
  reactStrictMode: true,
  logging: {
    fetches: {
      fullUrl: true
    }
  },
  eslint: {
    ignoreDuringBuilds: true
  },
  typescript: {
    ignoreBuildErrors: true
  },
  images: {
    unoptimized: true,
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'medusa-public-images.s3.eu-west-1.amazonaws.com'
      },
      {
        protocol: 'https',
        hostname: 'mercur-connect.s3.eu-central-1.amazonaws.com'
      },
      {
        protocol: 'https',
        hostname: 'api.mercurjs.com'
      },
      {
        protocol: 'http',
        hostname: 'localhost'
      },
      {
        protocol: 'https',
        hostname: 'api-sandbox.mercurjs.com',
        pathname: '/static/**'
      },
      {
        protocol: 'https',
        hostname: 'i.imgur.com'
      },
      {
        protocol: 'https',
        hostname: 's3.eu-central-1.amazonaws.com'
      },
      {
        protocol: 'https',
        hostname: 'mercur-testing.up.railway.app'
      },
      {
        protocol: 'https',
        hostname: '*.s3.*.amazonaws.com'
      },
      {
        protocol: 'https',
        hostname: '*.s3.amazonaws.com'
      },
      {
        protocol: 'https',
        hostname: '**'
      },
      ...(S3_HOSTNAME && S3_PATHNAME
        ? [
            {
              protocol: 'https' as const,
              hostname: S3_HOSTNAME,
              pathname: S3_PATHNAME
            }
          ]
        : [])
    ]
  },
  webpack: (config) => {
    config.resolve.alias = {
      ...config.resolve.alias,
      ...getReactAliases()
    };
    return config;
  }
};

export default nextConfig;
