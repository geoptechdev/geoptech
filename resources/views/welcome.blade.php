<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>{{ config('app.name', 'Laravel') }}</title>
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=instrument-sans:400,500,600" rel="stylesheet" />
        <style>
            *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
            body {
                font-family: 'Instrument Sans', system-ui, sans-serif;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                background: #FDFDFC;
                color: #1b1b18;
            }
            .container {
                text-align: center;
                padding: 2rem;
            }
            h1 {
                font-size: 2.5rem;
                font-weight: 600;
                margin-bottom: 0.5rem;
            }
            p {
                font-size: 1.125rem;
                color: #706f6c;
            }
            @media (prefers-color-scheme: dark) {
                body { background: #0a0a0a; color: #EDEDEC; }
                p { color: #A1A09A; }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Hello World</h1>
            <p>from Magic Containers</p>
        </div>
    </body>
</html>
