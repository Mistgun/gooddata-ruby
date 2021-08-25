# encoding: UTF-8
#
# Copyright (c) 2010-2017 GoodData Corporation. All rights reserved.
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

require 'gooddata/helpers/data_helper'
require 'gooddata/exceptions/invalid_env_error'

iam_params = {
  "redshift_client"=> {
    "connection"=> {
      "url"=> "jdbc:redshift:iam://explorer.cbrgkmwhlu9v.us-east-2.redshift.amazonaws.com:5439",
      "authentication"=> {
        "iam"=> {
          "dbUser"=> "redshiftdevunloader",
          "accessKeyId"=> ConnectionHelper::SECRETS[:redshift_access_key],
          "secretAccessKey"=> ConnectionHelper::SECRETS[:redshift_secret_key]
        }
      },
      "database"=> "dev",
      "schema"=> "lcm_integration_test"
    }
  },
  "input_source"=> {
    "type"=> "redshift",
    "query"=> "SELECT * FROM lcm_project_users order by client_id"
  }
}

basic_params = {
  "redshift_client"=> {
    "connection"=> {
      "url"=> "jdbc:redshift://explorer.cbrgkmwhlu9v.us-east-2.redshift.amazonaws.com:5439",
      "authentication"=> {
        "basic"=> {
          "userName"=> "cornflake",
          "password"=> ConnectionHelper::SECRETS[:redshift_password]
        }
      },
      "database"=> "dev",
      "schema"=> "lcm_integration_test"
    }
  },
  "input_source"=> {
    "type"=> "redshift",
    "query"=> "SELECT * FROM lcm_project_users order by client_id"
  }
}

basic_params_dynamic_source = {
  "redshift_client"=> {
    "connection"=> {
      "url"=> "jdbc:redshift://explorer.cbrgkmwhlu9v.us-east-2.redshift.amazonaws.com:5439",
      "authentication"=> {
        "basic"=> {
          "userName"=> "cornflake",
          "password"=> ConnectionHelper::SECRETS[:redshift_password]
        }
      },
      "database"=> "dev",
      "schema"=> "lcm_integration_test"
    }
  },
  "dynamic_params" => {
    "input_source"=> {
      "type"=> "redshift",
      "query"=> "SELECT * FROM lcm_project_users order by client_id"
    }
  }
}

basic_params_url_parameters = {
  "redshift_client"=> {
    "connection"=> {
      "url"=> "jdbc:redshift://explorer.cbrgkmwhlu9v.us-east-2.redshift.amazonaws.com:5439/?ssl=true",
      "authentication"=> {
        "basic"=> {
          "userName"=> "cornflake",
          "password"=> ConnectionHelper::SECRETS[:redshift_password]
        }
      },
      "database"=> "dev",
      "schema"=> "lcm_integration_test"
    }
  },
  "input_source"=> {
    "type"=> "redshift",
    "query"=> "SELECT * FROM lcm_project_users order by client_id"
  }
}

basic_params_without_schema = {
  "redshift_client"=> {
    "connection"=> {
      "url"=> "jdbc:redshift://explorer.cbrgkmwhlu9v.us-east-2.redshift.amazonaws.com:5439",
      "authentication"=> {
        "basic"=> {
          "userName"=> "cornflake",
          "password"=> ConnectionHelper::SECRETS[:redshift_password]
        }
      },
      "database"=> "dev"
    }
  },
  "input_source"=> {
    "type"=> "redshift",
    "query"=> "SELECT * FROM lcm_test order by client_id"
  }
}

snowflake_basic_params = {
  "snowflake_client"=> {
    "connection"=> {
      "url"=> "jdbc:snowflake://gooddata.snowflakecomputing.com",
      "authentication"=> {
        "basic"=> {
          "userName"=> "mekong-qa",
          "password"=> ConnectionHelper::SECRETS[:snowflake_password]
        }
      },
      "database"=> "PHONG_DEV",
      "warehouse"=> "PHONG_DEV_DWH"
    }
  },
  "input_source"=> {
    "type"=> "snowflake",
    "query"=> "SELECT * FROM customers where CP__CUSTKEY='cus3'"
  }
}

bigquery_basic_params = {
  "bigquery_client"=> {
    "connection"=> {
      "authentication"=> {
        "serviceAccount"=> {
          "clientEmail"=> "gdc-bigquery-pipe@gdc-us-dev.iam.gserviceaccount.com",
          }
      },
      "project"=> "gdc-us-dev",
      "schema"=> "lcm_test"
    }
  },
  "input_source"=> {
    "type"=> "bigquery",
    "query"=> "select * from employees order by EmployeeID"
  }
}

blob_storage_params = {
    "blobStorage_client"=> {
        "connectionString"=> ConnectionHelper::SECRETS[:blob_storage_connection],
        "container"=> "msftest",
        "path"=> "",
    },
    "input_source"=> {
        "type"=> "blobStorage",
        "file"=> "clients.csv"
    }
}

mssql_basic_params = {
  "input_source"=> {
    "type"=> "mssql",
    "query"=> "select * from do_not_touch_ruby.Opportunity",
  },
  "mssql_client" => {
    "connection" => {
      "url" => "jdbc:sqlserver://msf-test-database.na.intgdc.com:1433",
      "database" => "msf_it_test",
      "authentication" => {
        "basic" => {
          "userName" => "sa",
          "password" => "D0ntleakit",
        }
      },
      "sslMode" => "prefer"
    },
  },
}

describe 'data helper', :vcr do

  it 'connect to redshift with IAM authentication' do
    data_helper = GoodData::Helpers::DataSource.new(iam_params['input_source'])
    file_path = data_helper.realize(iam_params)
    puts "redshift iam: #{file_path}"
    data = File.open('spec/data/redshift_data2.csv').read
    expect(data).to eq File.open(file_path).read
  end

  it 'connect to redshift with BASIC authentication' do
    data_helper = GoodData::Helpers::DataSource.new(basic_params['input_source'])
    file_path = data_helper.realize(basic_params)
    puts "redshift basic 1: #{file_path}"
    data = File.open('spec/data/redshift_data2.csv').read
    expect(data).to eq File.open(file_path).read
  end

  it 'connect to redshift with BASIC authentication without schema' do
    data_helper = GoodData::Helpers::DataSource.new(basic_params_without_schema['input_source'])
    file_path = data_helper.realize(basic_params_without_schema)
    puts "redshift basic 2: #{file_path}"
    data = File.open('spec/data/redshift_data.csv').read
    expect(data).to eq File.open(file_path).read
  end

  it 'connect to redshift with BASIC authentication and dynamic source' do
    data_helper = GoodData::Helpers::DataSource.new(basic_params_dynamic_source['dynamic_params']['input_source'])
    file_path = data_helper.realize(basic_params_dynamic_source)
    puts "redshift basic 3: #{file_path}"
    data = File.open('spec/data/redshift_data2.csv').read
    expect(data).to eq File.open(file_path).read
  end

  it 'connect to redshift with BASIC authentication and url has parameter' do
    data_helper = GoodData::Helpers::DataSource.new(basic_params_url_parameters['input_source'])
    file_path = data_helper.realize(basic_params_url_parameters)
    puts "redshift basic 4: #{file_path}"
    data = File.open('spec/data/redshift_data2.csv').read
    expect(data).to eq File.open(file_path).read
  end

  it 'connect to snowflake with BASIC authentication' do
    data_helper = GoodData::Helpers::DataSource.new(snowflake_basic_params['input_source'])
    file_path = data_helper.realize(snowflake_basic_params)
    puts "snowflake: #{file_path}"
    data = File.open('spec/data/snowflake_data.csv').read
    expect(data).to eq File.open(file_path).read
  end

  it 'connect to bigquery with BASIC authentication' do
    encryption_key = ENV['GD_SPEC_PASSWORD'] || ENV['BIA_ENCRYPTION_KEY']
    bigquery_secret = File.open('spec/environment/bigquery_encrypted').read
    decrypted = GoodData::Helpers.decrypt(bigquery_secret, encryption_key)
    bigquery_basic_params['bigquery_client']['connection']['authentication']['serviceAccount']['privateKey'] = decrypted

    data_helper = GoodData::Helpers::DataSource.new(bigquery_basic_params['input_source'])
    file_path = data_helper.realize(bigquery_basic_params)
    puts "bigquery: #{file_path}"
    data = File.open('spec/data/bigquery_data.csv').read
    expect(data).to eq File.open(file_path).read
  end

  it 'connect to blob storage with connection string' do
    data_helper = GoodData::Helpers::DataSource.new(blob_storage_params['input_source'])
    file_path = data_helper.realize(blob_storage_params)
    data = File.open('spec/data/blobstorage_data.csv').read
    expect(data).to eq File.open(file_path).read
  end

  it 'connect to mssql with BASIC authentication' do
    data_helper = GoodData::Helpers::DataSource.new(mssql_basic_params['input_source'])
    file_path = data_helper.realize(mssql_basic_params)
    puts "MSSQL basic: #{file_path}"
    data = File.open('spec/data/mssql_data.csv').read
    expect(data).to eq File.open(file_path).read
  end
end
