package jsonanimatlas;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

import jsonanimatlas.Types._ParserType;
import haxe.Json;
using StringTools;
class Interp
{
    static var coolRepo:String = "https://github.com/MrNiz/JsonAnimAtlas";
    static var ver:String = "0.0.1";
    static var palVer:String = "";
    static function get_palVer()
    {
        palVer = Version.getPal();
        ver = Version.get();
    }

    /**
    * Converts system logic from Json to Xml totally correct (OR at its 99%) with different types.
    * Some of those "Types" is the "JsonNizAnimAtlas" that this type of Anim Atlas has a documentation in (URL) that can make it work.
    * Or a native use of Adobe Animate Json Atlas
    * For example:
    * ```json
    {
        // This example for old format.
        "Anims_yourAnim":
        [
            ["name", "X", "Y", "WIDTH", "HEIGHT", "_pivotX", "_pivotY"]
        ],
        "formatV": "0"
    }
    * ```
    * or uses for Adobe Animate Json Atlas.
    * ```json
        {
        "ATLAS": 
        {
        "SPRITES":[ 
        {"SPRITE" : {"name": "0000","x":98,"y":93,"w":98,"h":137,"rotated": false}},
        {"SPRITE" : {"name": "0001","x":0,"y":93,"w":98,"h":155,"rotated": false}},
        {"SPRITE" : {"name": "0002","x":0,"y":0,"w":214,"h":93,"rotated": false}}
        ]},
        "meta": {
        "app": "Adobe Animate",
        "version": "22.0.4.185",
        "image": "spritemap1.png",
        "format": "RGBA8888",
        "size": {"w":214,"h":248},
        "resolution": "1"
        }
        }
        
    * ```
    *
    * @param Data   Data is a `haxe.Json` file or a `String` of `Json` type is necessary to be able to convert it since this is literally what is necessary
    **/
    public static function convertToXML(Data:Dynamic):String
    {

        get_palVer();
        #if debug
        trace("New atlas parser  local ver: " + ver + " git ver: " + palVer);
        #end
        var json:Dynamic = Data;
        if (Data is String) json = Json.parse(Data);

        if (json.image == null) json.image = "UnknownSpriteMap";
        var _xml:String = '<?xml version="1.0" encoding="utf-8"?>\n<TextureAtlas imagePath="${json.image}.png">\n<!-- Worked in: JsonAnimAtlas ${ver} ${palVer != ver ? "(OutDated: " + palVer + ")" : ''} by: MrNiz-->\n<!-- ${coolRepo} -->\n';
        @:privateAccess var type:Types = cast (_ParserType._get(json), Types);
        
        switch (type)
        {
            case NizJson(v),SimpleEngineJson(v):
                switch (v)
                {
                    default:
                        throw "[jsonanimatlas.Interp]: Expected arguments. (Argument palversion/formatV is null!)";
                        // json { "anims": [ { "name":"", "width": 0, "height": 0, "pos": [0,0], "frameWidth": 0, "frameHeight": 0, "pivot": [0,0] } ] } 
                    case "1":
                        var anims:Array<Dynamic> = json.anims;
                        trace(anims);

                        for (i in anims)
                            {
                                var loopN:Int = 0;
                                var fields = Reflect.fields(i);
                                
                                var to_add:String = "<SubTexture ";
                                if (fields.length > 1)
                                    for (field in fields)
                                    {
                                        var di:Dynamic = Reflect.getProperty(i, field);
                                 
                                        if (field == "name")
                                                to_add += "name= \"" + di + getIndex(loopN) + "\"";
                                        else
                                                to_add += ' ${field}= "${di}"';
                                    }
                                    loopN += 1;
                                to_add += " />\n";
                                var expc =get_expected(to_add);
                                if (expc == "") // Make sure addAnim.
                                    _xml += to_add;
                                else
                                    throw "\nExpected arguemnt: " + expc;  
                                            
                                    
                            }
                }

            // case SimpleEngineJson(v):
            case AdobeAnimateTextureAtlas:
                    var anims:Array<Dynamic> = json.SPRITES;
                    for (i in anims)
                        {
                         var to_add:String = '<SubTexture name="anim' + " " + i.SPRITE.name + '"' + " width= " + i.SPRITE.w + " height= " + i.SPRITE.h
                         +  " x= " + i.SPRITE.x + " y= " + i.SPRITE.y + " rotated= " + i.SPRITE.rotated + "/>\n";
                         if (to_add.indexOf("null") != -1)
                            throw "Error in the SPRITESHEET Data: " + i.SPRITE.name;
                         _xml += to_add;
                        }

            default:
                throw "[jsonanimatlas.Interp]: Null Object Reference\nType is null!\nPlease report in " + coolRepo;

        }
        _xml += "</TextureAtlas>";

        return _xml;
    }
    static function get_expected(daAnim:String)
    {
        var rtr:String = "";
        var toSearch:Array<String> = ["name","width","height","x","y"];
        for (search in 0...toSearch.length)
           if(!daAnim.contains(toSearch[search]))
             rtr += toSearch[search];
            
        return rtr;
                
    }
    static function getIndex(num:Int) {
        var e= '0000'.length - ('${num}'.length);
        var rtr="";
        for(i in 0...e)
            rtr += "0";
        rtr += num;
        return rtr;

    }
}