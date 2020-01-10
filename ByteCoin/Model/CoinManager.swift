//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCurrency(_coinManager: CoinManager, currencyPrice: Double)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        let url = baseURL + currency
        performRequest(with: url)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let conversion = self.parseJSON(using: safeData) {
                        self.delegate?.didUpdateCurrency(_coinManager: self, currencyPrice: conversion)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(using currencyData: Data) -> Double? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CurrencyData.self, from: currencyData)
            let lastPrice = decodedData.last
            return lastPrice
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}
