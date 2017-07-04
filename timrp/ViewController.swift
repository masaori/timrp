//
//  ViewController.swift
//  timrp
//
//  Created by 広野雅織 on 2017/06/05.
//  Copyright © 2017年 Masaori Hirono. All rights reserved.
//

import Cocoa

var CHARACTER_MAP: [Int:String] = [
    1: "a",
    2: "b",
    3: "c",
    4: "d",
    5: "e",
    6: "f",
    7: "g",
    8: "h",
    9: "i",
    10: "j",
    11: "k",
    12: "l",
    13: "m",
    14: "n",
    15: "o",
    16: "p",
    17: "q",
    18: "r",
    19: "s",
    20: "t",
    21: "u",
    22: "v",
    23: "w",
    24: "u",
    25: "x",
    26: "y",
    27: "z",
    28: ".",
    29: " ",
    30: "\n",
]

class ViewController: NSViewController {
    @IBOutlet weak var currentNumberLabel: NSTextField!
    @IBOutlet weak var touchHandlerView: TouchHandlerView!

    var input: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        touchHandlerView.onCharacterUpdated = {
            if $0 == 31 {
                self.input = ""
            }
            self.input += CHARACTER_MAP[$0] ?? ""
            self.currentNumberLabel.stringValue = "\(self.input)"
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

