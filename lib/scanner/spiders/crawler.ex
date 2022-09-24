defmodule Scanner.Spiders.Crawler do
  @moduledoc """
  Defines Helper functions for crawling the etherscan.io transaction
  page
  """

  alias Crawly.ParsedItem

  alias Scanner.Spiders.Ethereum

  @etherscan_url "https://etherscan.io/tx"

  @doc """
  Given a transaction hash, it scaps the web page for the
  trasction and returns the payment

  """
  @spec scrap_transaction_page(tx_hash :: String.t(), opts :: Keyword.t()) :: Ethereum.t()
  def scrap_transaction_page(tx_hash, _opts \\ []) do
    url = "#{@etherscan_url}/#{tx_hash}"

    try do
      url
      |> Crawly.fetch(with: Ethereum)
      |> fetch_parsed_item()
    rescue
      _ ->
        :tx_not_found
    end
  end

  defp fetch_parsed_item({_, %ParsedItem{items: [item]}, _, _}), do: item
end
