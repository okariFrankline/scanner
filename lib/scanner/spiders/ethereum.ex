defmodule Scanner.Spiders.Ethereum do
  @moduledoc """
  This module is responsible for scrapping the etherscan web page
  showing information about the a trasction and returning the number
  of confirmed blocks
  """

  use Crawly.Spider

  alias Crawly.ParsedItem

  defstruct [:tx_hash, confirmed_blocks: 0]

  @block_selector "div span.u-label.u-label--xs.u-label--badge-in.u-label--secondary.ml-1"

  @doc_selector "div span#spanTxHash"

  @impl Crawly.Spider
  def base_url, do: "https://etherscan.io/tx"

  @impl Crawly.Spider
  def init(opts) do
    tx_hash = Keyword.fetch!(opts, :crawler_id)

    [start_urls: ["https://etherscan.io/tx/#{tx_hash}"]]
  end

  @impl Crawly.Spider
  def parse_item(%{body: body}) do
    %ParsedItem{items: [do_parse_item(body)], requests: []}
    |> IO.inspect()
  end

  defp do_parse_item(body) do
    body
    |> Floki.parse_document!()
    |> create_new_item()
  end

  defp create_new_item(doc) do
    %__MODULE__{tx_hash: get_tx_hash(doc), confirmed_blocks: get_confirmed_blocks(doc)}
  end

  defp get_tx_hash(document) do
    document
    |> Floki.find(@doc_selector)
    |> Floki.text()
    |> String.trim()
  end

  defp get_confirmed_blocks(document) do
    document
    |> Floki.find(@block_selector)
    |> Floki.text()
    |> extract_blocks()
  end

  defp extract_blocks(text) do
    text
    |> String.split(" ", parts: 2, trim: true)
    |> List.first()
    |> String.to_integer()
  end
end
