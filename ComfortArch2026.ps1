# ============================================================================
#  Comfort Arch 2026  -  대놓고 장난임을 알리는 화면보호기
# ----------------------------------------------------------------------------
#  * 전체화면으로 그림을 보여주고, 위쪽에 "장난이에요" 배너를 표시합니다.
#  * 볼륨을 전혀 건드리지 않습니다. (경고음/소리 없음)
#  * 작업표시줄을 잠그거나 숨기지 않습니다.
#  * 아무 키를 누르거나, 클릭하거나, 마우스를 움직이면 바로 닫힙니다.
#
#  그림 바꾸는 법: 이 스크립트와 같은 폴더에 center-photo.png 를 넣으면 그게 나옵니다.
#                 (다른 파일을 쓰려면 아래 $imageName 을 바꾸세요.)
# ============================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$imageName = 'center-photo.png'

# 스크립트/exe 가 있는 폴더를 안전하게 찾기 (ps2exe 로 빌드해도 동작)
$baseDir =
    if ($PSScriptRoot) { $PSScriptRoot }
    elseif ($MyInvocation.MyCommand.Path) { Split-Path -Parent $MyInvocation.MyCommand.Path }
    else { [System.IO.Path]::GetDirectoryName([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName) }

$imagePath = Join-Path $baseDir $imageName

$image = $null
if (Test-Path $imagePath) {
    try { $image = [System.Drawing.Image]::FromFile($imagePath) } catch { $image = $null }
}

# ----- 폼(창) 만들기 -----
$form = New-Object System.Windows.Forms.Form
$form.Text            = 'Comfort Arch 2026 (장난)'
$form.FormBorderStyle = 'None'
$form.WindowState     = 'Maximized'
$form.TopMost         = $true
$form.BackColor       = [System.Drawing.Color]::FromArgb(255, 211, 230)  # 파스텔 핑크
$form.KeyPreview      = $true
$form.Cursor          = [System.Windows.Forms.Cursors]::Default           # 커서 숨기지 않음

# 더블 버퍼링 (깜빡임 방지) - 보호된 속성이라 리플렉션으로 설정
$dbProp = $form.GetType().GetProperty('DoubleBuffered',
    [System.Reflection.BindingFlags]'Instance, NonPublic')
$dbProp.SetValue($form, $true, $null)

# ----- 그리기 -----
$form.Add_Paint({
    param($sender, $e)
    $g  = $e.Graphics
    $cw = $form.ClientSize.Width
    $ch = $form.ClientSize.Height

    # 배경 그라데이션 (핑크 -> 하늘색)
    $rect = New-Object System.Drawing.Rectangle(0, 0, $cw, $ch)
    $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect,
        [System.Drawing.Color]::FromArgb(255, 211, 230),
        [System.Drawing.Color]::FromArgb(207, 233, 255),
        [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal)
    $g.FillRectangle($grad, $rect)
    $grad.Dispose()

    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    if ($null -ne $image) {
        # 그림을 비율 유지하며 가운데에 맞춰 그리기 (레터박스)
        $margin = 120
        $maxW = $cw - ($margin * 2)
        $maxH = $ch - ($margin * 2)
        $scale = [Math]::Min($maxW / $image.Width, $maxH / $image.Height)
        if ($scale -gt 1) { $scale = 1 }  # 원본보다 크게 늘리지 않음
        $dw = [int]($image.Width  * $scale)
        $dh = [int]($image.Height * $scale)
        $dx = [int](($cw - $dw) / 2)
        $dy = [int](($ch - $dh) / 2)

        # 흰 액자
        $pad = 10
        $g.FillRectangle([System.Drawing.Brushes]::White,
            ($dx - $pad), ($dy - $pad), ($dw + $pad * 2), ($dh + $pad * 2))
        $g.DrawImage($image, $dx, $dy, $dw, $dh)
    }
    else {
        # 그림이 없을 때 안내
        $msg = "center-photo.png 를 이 폴더에 넣으면 그림이 나와요."
        $f2  = New-Object System.Drawing.Font('Segoe UI', 16)
        $sf2 = New-Object System.Drawing.StringFormat
        $sf2.Alignment = 'Center'; $sf2.LineAlignment = 'Center'
        $g.DrawString($msg, $f2,
            (New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(154, 111, 132))),
            (New-Object System.Drawing.RectangleF(0, 0, $cw, $ch)), $sf2)
        $f2.Dispose()
    }

    # 상단 "장난이에요" 배너
    $bannerH = 86
    $bBrush  = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(205, 255, 255, 255))
    $g.FillRectangle($bBrush, 0, 0, $cw, $bannerH)
    $bBrush.Dispose()

    $title = "장난용 화면보호기예요  —  놀라지 마세요 :)"
    $sub   = "아무 키나 누르거나 클릭하거나 마우스를 움직이면 닫혀요"
    $fTitle = New-Object System.Drawing.Font('Segoe UI', 22, [System.Drawing.FontStyle]::Bold)
    $fSub   = New-Object System.Drawing.Font('Segoe UI', 12)
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = 'Center'
    $ink = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(74, 59, 71))
    $g.DrawString($title, $fTitle, $ink, (New-Object System.Drawing.RectangleF(0, 14, $cw, 40)), $sf)
    $g.DrawString($sub,   $fSub,   $ink, (New-Object System.Drawing.RectangleF(0, 56, $cw, 24)), $sf)
    $fTitle.Dispose(); $fSub.Dispose(); $ink.Dispose()
})

# ----- 종료 조건: 아무 키 / 클릭 / 마우스 이동 -----
$script:startMouse = $null

$closeIt = { $form.Close() }

$form.Add_KeyDown($closeIt)
$form.Add_MouseDown($closeIt)
$form.Add_MouseMove({
    param($sender, $e)
    if ($null -eq $script:startMouse) { $script:startMouse = $e.Location; return }
    $dx = [Math]::Abs($e.X - $script:startMouse.X)
    $dy = [Math]::Abs($e.Y - $script:startMouse.Y)
    if ($dx -gt 40 -or $dy -gt 40) { $form.Close() }   # 살짝 떨림 무시, 크게 움직이면 종료
})

$form.Add_FormClosed({
    if ($null -ne $image) { $image.Dispose() }
})

[void][System.Windows.Forms.Application]::Run($form)
