defmodule SafeBoda.PromoCodeStore.Repo.Migrations.CreatePromoCodes do
  use Ecto.Migration

  def change do
    create table(:promo_codes) do
      add(:active?, :boolean)
      add(:code, :string)
      add(:description, :string)
      add(:expiration_date, :utc_datetime)
      add(:minimum_event_radius, :integer)
      add(:number_of_rides, :integer)
      add(:event_latitude, :float)
      add(:event_longitude, :float)
    end

    create(index(:promo_codes, [:code], unique: true))
  end
end
