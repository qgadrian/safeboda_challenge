defmodule SafeBoda.PromoCodeModel.Repo.Migrations.CreatePromoCodes do
  use Ecto.Migration

  def change do
    create table(:promo_codes) do
      add(:active?, :boolean)
      add(:description, :string)
      add(:expiration_date, :utc_datetime)
      add(:minimum_event_radius, :integer)
      add(:number_of_rides, :integer)
    end
  end
end
