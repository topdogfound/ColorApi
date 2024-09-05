<?php

namespace App\Http\Controllers;

require base_path('vendor/autoload.php');

use Illuminate\Http\Request;
use ourcodeworld\NameThatColor\ColorInterpreter;

class ColorController extends Controller
{
    public function convert($hexcode)
    {
        $instance = new ColorInterpreter();
        $result = $instance->name($hexcode);

        // 1. Print the human name e.g "Deep Sea"
        echo $result["name"] . "\n";

        // 2. Print the hex code of the closest color with a name e.g "#01826B"
        echo $result["hex"] . "\n";

        return response()->json($result["name"]);
    }
}
