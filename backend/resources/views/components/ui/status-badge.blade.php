@props(['status'=>'','map'=>null])
@php
    $m = $map ?? [
        'active'=>['Aktif','success'],'draft'=>['Draft','neutral'],'expired'=>['Kadaluarsa','neutral'],'cancelled'=>['Dibatalkan','danger'],
        'target_reached'=>['Target Tercapai','info'],'completed'=>['Selesai','success'],'fulfillment'=>['Fulfillment','info'],
        'pending'=>['Menunggu','warning'],'paid'=>['Lunas','success'],'waiting_qris'=>['Menunggu QRIS','warning'],
        'validated'=>['Tervalidasi','success'],'rejected'=>['Ditolak','danger'],
        'submitted'=>['Menunggu Respon','warning'],'accepted'=>['Diterima','info'],'awaiting_payment'=>['Menunggu Bayar','warning'],
        'processing'=>['Diproses','info'],'shipped'=>['Dikirim','info'],
        'pending_verification'=>['Menunggu Verifikasi','warning'],'verified'=>['Terverifikasi','success'],'suspended'=>['Ditangguhkan','danger'],
        'pending_moderation'=>['Menunggu Moderasi','warning'],
        'open'=>['Terbuka','danger'],'in_review'=>['Direview','warning'],'resolved'=>['Terselesaikan','success'],'closed'=>['Ditutup','neutral'],
    ];
    $c = $m[$status] ?? [ucfirst(str_replace('_',' ',$status)),'neutral'];
@endphp
<span class="badge badge-{{ $c[1] }}" {{ $attributes }}>{{ $c[0] }}</span>
