namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Question extends Model
{
    use HasFactory;

    protected $fillable = ['paper_id', 'question_text', 'marks', 'order'];

    protected $casts = [
        'marks' => 'integer',
        'order' => 'integer',
    ];

    public function paper()
    {
        return $this->belongsTo(Paper::class);
    }

    public function answers()
    {
        return $this->hasMany(Answer::class);
    }
}