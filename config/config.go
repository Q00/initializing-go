package config

import (
	"github.com/spf13/viper"
	"log"
	"strings"
	"sync"
)

type ServerConfig struct {
	Address string
	Port    int64
}

type DBConfig struct {
	Host         string `mapstructure:"hostname"`
	Port         int64
	User         string `mapstructure:"username"`
	Password     string
	DBName       string `mapstructure:"db"`
	MaxOpenConns int
	MaxIdleConns int
}

type Context struct {
	Timeout int
}

type Configuration struct {
	Server  ServerConfig `mapstructure:"server"`
	Context Context      `mapstructure:"context"`
	DB      DBConfig     `mapstructure:"DB"`
}

// singleton
var config *Configuration
var once sync.Once

func LoadConfig() *Configuration {
	once.Do(func() {
		viper.SetConfigName("config")
		viper.SetConfigType("toml")
		viper.AddConfigPath(".")
		viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))
		viper.AutomaticEnv()

		err := viper.ReadInConfig()
		if err != nil {
			log.Fatal("error reading config")
			panic(err)
		}

		err = viper.Unmarshal(&config)
		if err != nil {
			log.Fatal("error unmarshalling config")
			panic(err)
		}
	})

	return config
}
