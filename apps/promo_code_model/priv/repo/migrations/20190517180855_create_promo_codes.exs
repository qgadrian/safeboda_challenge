defmodule SafeBoda.PromoCodeModel.Repo.Migrations.CreatePromoCodes do
  use Ecto.Migration

  def change do
    create table(:promo_codes) do
      add(:description, :string)
      add(:active?, :boolean)
      add(:expiration_date, :utc_datetime)
    end
  end
end
