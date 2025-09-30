<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Subject;
use App\Models\Paper;
use App\Models\Question;
use App\Models\Answer;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Create test user
        User::create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => Hash::make('password123'),
        ]);

        // Create subjects
        $subjects = [
            ['name' => 'Mathematics', 'code' => 'MATH', 'description' => 'Mathematics papers'],
            ['name' => 'Physics', 'code' => 'PHYS', 'description' => 'Physics papers'],
            ['name' => 'Chemistry', 'code' => 'CHEM', 'description' => 'Chemistry papers'],
            ['name' => 'Biology', 'code' => 'BIO', 'description' => 'Biology papers'],
            ['name' => 'Computer Science', 'code' => 'CS', 'description' => 'Computer Science papers'],
        ];

        foreach ($subjects as $subjectData) {
            $subject = Subject::create($subjectData);

            // Create papers for each subject
            for ($year = 2020; $year <= 2024; $year++) {
                $paper = Paper::create([
                    'subject_id' => $subject->id,
                    'year' => $year,
                    'title' => "{$subject->name} Paper {$year}",
                    'description' => "Annual examination paper for {$subject->name} - {$year}",
                ]);

                // Create questions for each paper
                for ($i = 1; $i <= 10; $i++) {
                    $question = Question::create([
                        'paper_id' => $paper->id,
                        'question_text' => "Question {$i} for {$subject->name} {$year}: " . $this->generateSampleQuestion($subject->code),
                        'marks' => rand(1, 5),
                        'order' => $i,
                    ]);

                    // Create multiple choice answers
                    $answers = [
                        ['answer_text' => 'Option A: ' . $this->generateSampleAnswer(), 'is_correct' => true],
                        ['answer_text' => 'Option B: ' . $this->generateSampleAnswer(), 'is_correct' => false],
                        ['answer_text' => 'Option C: ' . $this->generateSampleAnswer(), 'is_correct' => false],
                        ['answer_text' => 'Option D: ' . $this->generateSampleAnswer(), 'is_correct' => false],
                    ];

                    shuffle($answers);

                    foreach ($answers as $answerData) {
                        Answer::create([
                            'question_id' => $question->id,
                            'answer_text' => $answerData['answer_text'],
                            'is_correct' => $answerData['is_correct'],
                        ]);
                    }
                }
            }
        }
    }

    private function generateSampleQuestion($code): string
    {
        $questions = [
            'MATH' => 'Solve the equation x² + 5x + 6 = 0',
            'PHYS' => 'Calculate the velocity of an object with mass 10kg',
            'CHEM' => 'Balance the chemical equation H₂ + O₂ → H₂O',
            'BIO' => 'Describe the process of photosynthesis',
            'CS' => 'What is the time complexity of binary search?',
        ];

        return $questions[$code] ?? 'Sample question text';
    }

    private function generateSampleAnswer(): string
    {
        $answers = [
            'This is a correct/incorrect answer',
            'Sample answer option',
            'Another possible answer',
            'Alternative solution',
        ];

        return $answers[array_rand($answers)];
    }
}
