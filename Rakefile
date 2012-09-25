require "bundler"
Bundler.require

namespace :db do

  desc "Run database migrations"
  task :migrate do
    db = RDO.connect(ENV["DATABASE_URL"])

    db.execute(<<-END)
    CREATE SEQUENCE cars_id_seq
    END

    db.execute(<<-END)
    CREATE TABLE cars (
      id integer DEFAULT nextval('cars_id_seq'),
      identifier integer,
      digest CHARACTER(40),
      year integer,
      model character varying,
      km integer,
      transmission character varying,
      auction_grade character varying,
      image character varying,
      link character varying,

      CONSTRAINT cars_pkey PRIMARY KEY (id)
    )
    END

    db.execute(<<-END)
    ALTER SEQUENCE cars_id_seq OWNED BY cars.id
    END
  end

  desc "Drop table(s)"
  task :wipe do
    RDO.connect(ENV["DATABASE_URL"]).execute(<<-END)
    DROP TABLE cars
    END
  end

end
